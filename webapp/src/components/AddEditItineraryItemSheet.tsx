import { useState } from 'react';
import type { ItineraryItem, ItineraryKind } from '../db/db';
import { db, newId } from '../db/db';
import { KIND_EMOJI, KIND_LABELS } from '../lib/format';
import { geocodeSearch, type GeocodeResult } from '../lib/geocode';

interface Props {
  tripId: string;
  item?: ItineraryItem;
  onClose: () => void;
}

const KINDS: ItineraryKind[] = ['flight', 'hotel', 'activity', 'note'];

function toLocalInput(iso?: string): string {
  if (!iso) return '';
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export default function AddEditItineraryItemSheet({ tripId, item, onClose }: Props) {
  const [kind, setKind] = useState<ItineraryKind>(item?.kind ?? 'activity');
  const [title, setTitle] = useState(item?.title ?? '');
  const [location, setLocation] = useState(item?.location ?? '');
  const [lat, setLat] = useState<number | undefined>(item?.lat);
  const [lon, setLon] = useState<number | undefined>(item?.lon);
  const [start, setStart] = useState(toLocalInput(item?.start) || toLocalInput(new Date().toISOString()));
  const [notes, setNotes] = useState(item?.notes ?? '');
  const [geoResults, setGeoResults] = useState<GeocodeResult[]>([]);
  const [searching, setSearching] = useState(false);

  const canSave = title.trim().length > 0 && start.length > 0;

  async function searchLocation() {
    if (!location.trim()) return;
    setSearching(true);
    try {
      const results = await geocodeSearch(location);
      setGeoResults(results);
    } finally {
      setSearching(false);
    }
  }

  function pickResult(r: GeocodeResult) {
    setLocation(r.displayName);
    setLat(r.lat);
    setLon(r.lon);
    setGeoResults([]);
  }

  async function save() {
    if (!canSave) return;
    const startISO = new Date(start).toISOString();
    if (item) {
      await db.itineraryItems.update(item.id, { kind, title, location, lat, lon, start: startISO, notes });
    } else {
      await db.itineraryItems.add({
        id: newId(),
        tripId,
        kind,
        title,
        location,
        lat,
        lon,
        start: startISO,
        notes,
        createdAt: Date.now(),
      });
    }
    onClose();
  }

  async function remove() {
    if (!item) return;
    await db.itineraryItems.delete(item.id);
    onClose();
  }

  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <h2>{item ? 'Eintrag bearbeiten' : 'Neuer Eintrag'}</h2>

        <div className="field">
          <label>Art</label>
          <div className="segmented" style={{ margin: 0 }}>
            {KINDS.map((k) => (
              <button key={k} className={kind === k ? 'active' : ''} onClick={() => setKind(k)} type="button">
                {KIND_EMOJI[k]} {KIND_LABELS[k]}
              </button>
            ))}
          </div>
        </div>

        <div className="field">
          <label>Titel</label>
          <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="z.B. LH 123 nach Rom" autoFocus />
        </div>

        <div className="field">
          <label>Ort {lat != null && <span style={{ color: 'var(--success)' }}>· auf Karte</span>}</label>
          <div className="row">
            <input
              value={location}
              onChange={(e) => {
                setLocation(e.target.value);
                setLat(undefined);
                setLon(undefined);
              }}
              placeholder="z.B. Rom, Italien"
            />
            <button type="button" className="btn btn-secondary" style={{ flex: '0 0 auto', padding: '10px 14px' }} onClick={searchLocation}>
              {searching ? '…' : 'Suchen'}
            </button>
          </div>
          {geoResults.length > 0 && (
            <div className="card" style={{ marginTop: 8, padding: 8 }}>
              {geoResults.map((r, i) => (
                <div
                  key={i}
                  onClick={() => pickResult(r)}
                  style={{ padding: '8px 6px', fontSize: 14, cursor: 'pointer', borderBottom: i < geoResults.length - 1 ? '1px solid var(--border)' : undefined }}
                >
                  📍 {r.displayName}
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="field">
          <label>Datum & Uhrzeit</label>
          <input type="datetime-local" value={start} onChange={(e) => setStart(e.target.value)} />
        </div>

        <div className="field">
          <label>Notizen</label>
          <textarea value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Buchungsnummer, Gate, Zimmer, ..." />
        </div>

        <div className="sheet-actions">
          {item && (
            <button className="btn btn-danger" onClick={remove}>
              Löschen
            </button>
          )}
          <button className="btn btn-secondary" onClick={onClose}>
            Abbrechen
          </button>
          <button className="btn btn-primary" onClick={save} disabled={!canSave}>
            Speichern
          </button>
        </div>
      </div>
    </div>
  );
}

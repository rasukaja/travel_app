import { useState } from 'react';
import type { Trip } from '../db/db';
import { db, newId } from '../db/db';

const EMOJI_CHOICES = ['✈️', '🏖️', '🏔️', '🏙️', '🚗', '🚢', '🎒', '⛷️'];

interface Props {
  trip?: Trip;
  onClose: () => void;
  onDeleted?: () => void;
}

export default function AddEditTripSheet({ trip, onClose, onDeleted }: Props) {
  const [name, setName] = useState(trip?.name ?? '');
  const [destination, setDestination] = useState(trip?.destination ?? '');
  const [startDate, setStartDate] = useState(trip?.startDate ?? '');
  const [endDate, setEndDate] = useState(trip?.endDate ?? '');
  const [emoji, setEmoji] = useState(trip?.coverEmoji ?? EMOJI_CHOICES[0]);

  const canSave = name.trim().length > 0 && startDate && endDate && startDate <= endDate;

  async function save() {
    if (!canSave) return;
    if (trip) {
      await db.trips.update(trip.id, { name, destination, startDate, endDate, coverEmoji: emoji });
    } else {
      await db.trips.add({
        id: newId(),
        name,
        destination,
        startDate,
        endDate,
        coverEmoji: emoji,
        createdAt: Date.now(),
      });
    }
    onClose();
  }

  async function remove() {
    if (!trip) return;
    if (!confirm(`"${trip.name}" wirklich löschen? Alle Einträge, Packliste und Dokumente werden mitgelöscht.`)) return;
    await db.transaction('rw', db.trips, db.itineraryItems, db.packingItems, db.documents, async () => {
      await db.itineraryItems.where('tripId').equals(trip.id).delete();
      await db.packingItems.where('tripId').equals(trip.id).delete();
      await db.documents.where('tripId').equals(trip.id).delete();
      await db.trips.delete(trip.id);
    });
    if (onDeleted) onDeleted();
    else onClose();
  }

  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <h2>{trip ? 'Reise bearbeiten' : 'Neue Reise'}</h2>

        <div className="field">
          <label>Emoji</label>
          <div className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
            {EMOJI_CHOICES.map((e) => (
              <button
                key={e}
                type="button"
                onClick={() => setEmoji(e)}
                className="checkbox"
                style={{
                  width: 40,
                  height: 40,
                  fontSize: 20,
                  borderColor: emoji === e ? 'var(--accent)' : undefined,
                  borderWidth: emoji === e ? 2 : 2,
                }}
              >
                {e}
              </button>
            ))}
          </div>
        </div>

        <div className="field">
          <label>Name der Reise</label>
          <input value={name} onChange={(e) => setName(e.target.value)} placeholder="z.B. Sommerurlaub Italien" autoFocus />
        </div>

        <div className="field">
          <label>Ziel</label>
          <input value={destination} onChange={(e) => setDestination(e.target.value)} placeholder="z.B. Rom, Italien" />
        </div>

        <div className="row">
          <div className="field">
            <label>Start</label>
            <input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} />
          </div>
          <div className="field">
            <label>Ende</label>
            <input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} />
          </div>
        </div>

        <div className="sheet-actions">
          {trip && (
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

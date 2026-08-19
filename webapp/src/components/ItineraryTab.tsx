import { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, type ItineraryItem } from '../db/db';
import { KIND_EMOJI, KIND_LABELS, formatDateTime } from '../lib/format';
import AddEditItineraryItemSheet from './AddEditItineraryItemSheet';
import { itemsStartingSoon } from '../lib/reminders';

export default function ItineraryTab({ tripId }: { tripId: string }) {
  const [editing, setEditing] = useState<ItineraryItem | 'new' | null>(null);
  const items = useLiveQuery(
    () => db.itineraryItems.where('tripId').equals(tripId).sortBy('start'),
    [tripId],
  );

  const soon = items ? itemsStartingSoon(items) : [];

  return (
    <div className="content" style={{ paddingTop: 0 }}>
      {soon.length > 0 && (
        <div className="banner">
          <strong>Bald dran</strong>
          {soon.slice(0, 3).map((s) => (
            <div key={s.id}>
              {KIND_EMOJI[s.kind]} {s.title} · {formatDateTime(s.start)}
            </div>
          ))}
        </div>
      )}

      {items && items.length === 0 && (
        <div className="empty-state">
          <span className="emoji">🗓️</span>
          Noch keine Einträge. Füge Flüge, Hotels, Aktivitäten oder Notizen hinzu.
        </div>
      )}

      {items?.map((item) => (
        <div key={item.id} className="card" onClick={() => setEditing(item)}>
          <div className="list-item">
            <span className="emoji">{KIND_EMOJI[item.kind]}</span>
            <div className="meta">
              <div className="title">{item.title}</div>
              <div className="sub">
                {formatDateTime(item.start)}
                {item.location ? ` · ${item.location}` : ''}
              </div>
              {item.notes && <div className="sub">{item.notes}</div>}
            </div>
            <span className="chip">{KIND_LABELS[item.kind]}</span>
          </div>
        </div>
      ))}

      <button className="fab" onClick={() => setEditing('new')} aria-label="Eintrag hinzufügen">
        +
      </button>

      {editing && (
        <AddEditItineraryItemSheet
          tripId={tripId}
          item={editing === 'new' ? undefined : editing}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  );
}

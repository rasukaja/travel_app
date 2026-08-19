import { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, newId } from '../db/db';
import { PACKING_TEMPLATES, PACKING_CATEGORIES } from '../lib/packingTemplates';

export default function PackingTab({ tripId }: { tripId: string }) {
  const [newLabel, setNewLabel] = useState('');
  const [showTemplates, setShowTemplates] = useState(false);
  const items = useLiveQuery(
    () => db.packingItems.where('tripId').equals(tripId).sortBy('createdAt'),
    [tripId],
  );

  const checkedCount = items?.filter((i) => i.checked).length ?? 0;
  const total = items?.length ?? 0;

  async function addItem(label: string, category = 'Eigene') {
    if (!label.trim()) return;
    await db.packingItems.add({
      id: newId(),
      tripId,
      label: label.trim(),
      checked: false,
      category,
      createdAt: Date.now(),
    });
  }

  async function toggle(id: string, checked: boolean) {
    await db.packingItems.update(id, { checked: !checked });
  }

  async function remove(id: string) {
    await db.packingItems.delete(id);
  }

  async function applyTemplate(category: string) {
    const existingLabels = new Set((items ?? []).map((i) => i.label.toLowerCase()));
    const toAdd = PACKING_TEMPLATES[category].filter((l) => !existingLabels.has(l.toLowerCase()));
    await db.packingItems.bulkAdd(
      toAdd.map((label) => ({
        id: newId(),
        tripId,
        label,
        checked: false,
        category,
        createdAt: Date.now(),
      })),
    );
    setShowTemplates(false);
  }

  return (
    <div className="content" style={{ paddingTop: 0 }}>
      {total > 0 && (
        <div className="banner">
          <strong>Fortschritt</strong>
          {checkedCount} von {total} gepackt
        </div>
      )}

      <div className="field row">
        <input
          value={newLabel}
          onChange={(e) => setNewLabel(e.target.value)}
          placeholder="Neuer Gegenstand..."
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              addItem(newLabel);
              setNewLabel('');
            }
          }}
        />
        <button
          className="btn btn-secondary"
          style={{ flex: '0 0 auto', padding: '10px 14px' }}
          onClick={() => setShowTemplates((s) => !s)}
        >
          Vorlagen
        </button>
      </div>

      {showTemplates && (
        <div className="card">
          {PACKING_CATEGORIES.map((cat) => (
            <button key={cat} className="btn btn-secondary" style={{ width: '100%', marginBottom: 8 }} onClick={() => applyTemplate(cat)}>
              + {cat}-Liste hinzufügen
            </button>
          ))}
        </div>
      )}

      {items && items.length === 0 && !showTemplates && (
        <div className="empty-state">
          <span className="emoji">🎒</span>
          Noch nichts auf der Packliste. Füge Dinge hinzu oder nutze eine Vorlage.
        </div>
      )}

      {items?.map((item) => (
        <div key={item.id} className="card">
          <div className="list-item" style={{ alignItems: 'center' }}>
            <div className={`checkbox ${item.checked ? 'checked' : ''}`} onClick={() => toggle(item.id, item.checked)}>
              {item.checked && '✓'}
            </div>
            <div className="meta">
              <div className="title" style={{ textDecoration: item.checked ? 'line-through' : undefined, opacity: item.checked ? 0.5 : 1 }}>
                {item.label}
              </div>
              <div className="sub">{item.category}</div>
            </div>
            <button className="icon-btn" onClick={() => remove(item.id)} aria-label="Entfernen">
              ✕
            </button>
          </div>
        </div>
      ))}
    </div>
  );
}

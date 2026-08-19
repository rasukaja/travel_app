import { useEffect, useRef, useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db, newId, type TravelDocument } from '../db/db';
import { DOCUMENT_CATEGORY_LABELS } from '../lib/format';

const CATEGORIES: TravelDocument['category'][] = ['passport', 'ticket', 'confirmation', 'other'];

function DocThumb({ doc, onOpen, onDelete }: { doc: TravelDocument; onOpen: () => void; onDelete: () => void }) {
  const [url, setUrl] = useState<string | null>(null);

  useEffect(() => {
    const objUrl = URL.createObjectURL(doc.blob);
    setUrl(objUrl);
    return () => URL.revokeObjectURL(objUrl);
  }, [doc.blob]);

  return (
    <div className="doc-thumb" onClick={onOpen}>
      {url && <img src={url} alt={doc.title} />}
      <div className="label">
        {doc.title}
        <br />
        <span style={{ opacity: 0.8 }}>{DOCUMENT_CATEGORY_LABELS[doc.category]}</span>
      </div>
      <button
        className="icon-btn"
        style={{ position: 'absolute', top: 4, right: 4, background: 'rgba(0,0,0,0.4)', color: 'white', borderRadius: '50%', width: 26, height: 26, justifyContent: 'center' }}
        onClick={(e) => {
          e.stopPropagation();
          onDelete();
        }}
      >
        ✕
      </button>
    </div>
  );
}

export default function DocumentsTab({ tripId }: { tripId: string }) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [category, setCategory] = useState<TravelDocument['category']>('ticket');
  const [viewing, setViewing] = useState<TravelDocument | null>(null);
  const [viewingUrl, setViewingUrl] = useState<string | null>(null);

  const docs = useLiveQuery(() => db.documents.where('tripId').equals(tripId).sortBy('createdAt'), [tripId]);

  useEffect(() => {
    if (!viewing) {
      setViewingUrl(null);
      return;
    }
    const url = URL.createObjectURL(viewing.blob);
    setViewingUrl(url);
    return () => URL.revokeObjectURL(url);
  }, [viewing]);

  async function handleFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    for (const file of Array.from(files)) {
      await db.documents.add({
        id: newId(),
        tripId,
        title: file.name.replace(/\.[a-zA-Z0-9]+$/, '') || 'Dokument',
        category,
        mimeType: file.type,
        blob: file,
        createdAt: Date.now(),
      });
    }
    if (fileInputRef.current) fileInputRef.current.value = '';
  }

  async function remove(id: string) {
    await db.documents.delete(id);
  }

  return (
    <div className="content" style={{ paddingTop: 0 }}>
      <div className="field">
        <label>Kategorie für neue Fotos</label>
        <select value={category} onChange={(e) => setCategory(e.target.value as TravelDocument['category'])}>
          {CATEGORIES.map((c) => (
            <option key={c} value={c}>
              {DOCUMENT_CATEGORY_LABELS[c]}
            </option>
          ))}
        </select>
      </div>

      <button className="btn btn-primary" style={{ width: '100%', marginBottom: 16 }} onClick={() => fileInputRef.current?.click()}>
        📷 Foto hinzufügen
      </button>
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        multiple
        style={{ display: 'none' }}
        onChange={(e) => handleFiles(e.target.files)}
      />

      {docs && docs.length === 0 && (
        <div className="empty-state">
          <span className="emoji">🛂</span>
          Noch keine Dokumente. Fotografiere Pass, Tickets oder Buchungsbestätigungen.
        </div>
      )}

      {docs && docs.length > 0 && (
        <div className="doc-grid">
          {docs.map((doc) => (
            <DocThumb key={doc.id} doc={doc} onOpen={() => setViewing(doc)} onDelete={() => remove(doc.id)} />
          ))}
        </div>
      )}

      {viewing && viewingUrl && (
        <div className="sheet-backdrop" onClick={() => setViewing(null)} style={{ alignItems: 'center', padding: 20 }}>
          <img src={viewingUrl} alt={viewing.title} style={{ maxWidth: '100%', maxHeight: '85vh', borderRadius: 12 }} />
        </div>
      )}
    </div>
  );
}

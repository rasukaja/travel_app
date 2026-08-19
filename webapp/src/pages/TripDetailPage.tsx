import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db/db';
import ItineraryTab from '../components/ItineraryTab';
import PackingTab from '../components/PackingTab';
import DocumentsTab from '../components/DocumentsTab';
import RouteMapTab from '../components/RouteMapTab';
import AddEditTripSheet from '../components/AddEditTripSheet';

type Tab = 'itinerary' | 'packing' | 'documents' | 'map';

const TABS: { id: Tab; label: string }[] = [
  { id: 'itinerary', label: 'Zeitstrahl' },
  { id: 'packing', label: 'Packliste' },
  { id: 'documents', label: 'Dokumente' },
  { id: 'map', label: 'Karte' },
];

export default function TripDetailPage() {
  const { tripId } = useParams<{ tripId: string }>();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('itinerary');
  const [editingTrip, setEditingTrip] = useState(false);

  const trip = useLiveQuery(() => (tripId ? db.trips.get(tripId) : undefined), [tripId]);

  if (!tripId) return null;

  return (
    <>
      <div className="top-bar">
        <button className="icon-btn" onClick={() => navigate('/')}>
          ‹ Reisen
        </button>
        <h1>{trip ? `${trip.coverEmoji} ${trip.name}` : 'Lädt…'}</h1>
        <button className="icon-btn" onClick={() => setEditingTrip(true)}>
          Bearbeiten
        </button>
      </div>

      <div className="segmented" style={{ marginTop: 12 }}>
        {TABS.map((t) => (
          <button key={t.id} className={tab === t.id ? 'active' : ''} onClick={() => setTab(t.id)}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'itinerary' && <ItineraryTab tripId={tripId} />}
      {tab === 'packing' && <PackingTab tripId={tripId} />}
      {tab === 'documents' && <DocumentsTab tripId={tripId} />}
      {tab === 'map' && <RouteMapTab tripId={tripId} />}

      {editingTrip && trip && (
        <AddEditTripSheet
          trip={trip}
          onClose={() => setEditingTrip(false)}
          onDeleted={() => navigate('/')}
        />
      )}
    </>
  );
}

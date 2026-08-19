import { useState } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { useNavigate } from 'react-router-dom';
import { db } from '../db/db';
import { formatDateRange, daysUntil } from '../lib/format';
import AddEditTripSheet from '../components/AddEditTripSheet';

export default function TripListPage() {
  const navigate = useNavigate();
  const [showAdd, setShowAdd] = useState(false);
  const trips = useLiveQuery(() => db.trips.orderBy('startDate').toArray(), []);

  return (
    <>
      <div className="top-bar">
        <h1>Meine Reisen</h1>
      </div>

      <div className="content">
        {trips && trips.length === 0 && (
          <div className="empty-state">
            <span className="emoji">🧳</span>
            Noch keine Reisen angelegt.
            <br />
            Tippe unten rechts auf + um loszulegen.
          </div>
        )}

        {trips?.map((trip) => {
          const days = daysUntil(trip.startDate);
          return (
            <div key={trip.id} className="card" onClick={() => navigate(`/trip/${trip.id}`)}>
              <div className="list-item">
                <span className="emoji">{trip.coverEmoji}</span>
                <div className="meta">
                  <div className="title">{trip.name}</div>
                  <div className="sub">
                    {trip.destination ? `${trip.destination} · ` : ''}
                    {formatDateRange(trip.startDate, trip.endDate)}
                  </div>
                  {days >= 0 && days <= 60 && (
                    <span className="chip" style={{ marginTop: 6, display: 'inline-block' }}>
                      {days === 0 ? 'Heute geht’s los' : `in ${days} Tag${days === 1 ? '' : 'en'}`}
                    </span>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <button className="fab" onClick={() => setShowAdd(true)} aria-label="Neue Reise">
        +
      </button>

      {showAdd && <AddEditTripSheet onClose={() => setShowAdd(false)} />}
    </>
  );
}

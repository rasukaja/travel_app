import { useLiveQuery } from 'dexie-react-hooks';
import { MapContainer, TileLayer, Marker, Popup, Polyline } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { db } from '../db/db';
import { KIND_EMOJI, formatDateTime } from '../lib/format';

function emojiIcon(emoji: string) {
  return L.divIcon({
    html: `<div style="font-size:26px;line-height:1;filter:drop-shadow(0 1px 2px rgba(0,0,0,.4))">${emoji}</div>`,
    className: '',
    iconSize: [30, 30],
    iconAnchor: [15, 26],
  });
}

export default function RouteMapTab({ tripId }: { tripId: string }) {
  const items = useLiveQuery(() => db.itineraryItems.where('tripId').equals(tripId).sortBy('start'), [tripId]);
  const located = items?.filter((i) => i.lat != null && i.lon != null) ?? [];

  if (items && items.length > 0 && located.length === 0) {
    return (
      <div className="content" style={{ paddingTop: 0 }}>
        <div className="empty-state">
          <span className="emoji">🗺️</span>
          Für keinen Eintrag ist ein Ort mit Koordinaten hinterlegt.
          <br />
          Öffne einen Eintrag und suche den Ort über „Suchen“, um ihn auf der Karte zu sehen.
        </div>
      </div>
    );
  }

  if (located.length === 0) {
    return (
      <div className="content" style={{ paddingTop: 0 }}>
        <div className="empty-state">
          <span className="emoji">🗺️</span>
          Noch keine Orte auf der Karte. Füge zuerst Einträge im Zeitstrahl hinzu.
        </div>
      </div>
    );
  }

  const center: [number, number] = [located[0].lat!, located[0].lon!];
  const path: [number, number][] = located.map((i) => [i.lat!, i.lon!]);

  return (
    <div style={{ height: 'calc(100vh - 160px)', minHeight: 320 }}>
      <MapContainer center={center} zoom={5} style={{ height: '100%', width: '100%' }} scrollWheelZoom={true}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {path.length > 1 && <Polyline positions={path} pathOptions={{ color: '#0a84ff', weight: 3, opacity: 0.7 }} />}
        {located.map((item) => (
          <Marker key={item.id} position={[item.lat!, item.lon!]} icon={emojiIcon(KIND_EMOJI[item.kind])}>
            <Popup>
              <strong>{item.title}</strong>
              <br />
              {formatDateTime(item.start)}
              {item.location && (
                <>
                  <br />
                  {item.location}
                </>
              )}
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}

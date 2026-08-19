import { Routes, Route } from 'react-router-dom';
import TripListPage from './pages/TripListPage';
import TripDetailPage from './pages/TripDetailPage';

export default function App() {
  return (
    <div className="app-shell">
      <Routes>
        <Route path="/" element={<TripListPage />} />
        <Route path="/trip/:tripId" element={<TripDetailPage />} />
      </Routes>
    </div>
  );
}

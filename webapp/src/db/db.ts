import Dexie, { type EntityTable } from 'dexie';

export type ItineraryKind = 'flight' | 'hotel' | 'activity' | 'note';

export interface Trip {
  id: string;
  name: string;
  destination: string;
  startDate: string; // ISO date (yyyy-mm-dd)
  endDate: string; // ISO date (yyyy-mm-dd)
  coverEmoji: string;
  createdAt: number;
}

export interface ItineraryItem {
  id: string;
  tripId: string;
  kind: ItineraryKind;
  title: string;
  location: string;
  lat?: number;
  lon?: number;
  start: string; // ISO datetime
  end?: string; // ISO datetime
  notes: string;
  createdAt: number;
}

export interface PackingItem {
  id: string;
  tripId: string;
  label: string;
  checked: boolean;
  category: string;
  createdAt: number;
}

export interface TravelDocument {
  id: string;
  tripId: string;
  title: string;
  category: 'passport' | 'ticket' | 'confirmation' | 'other';
  mimeType: string;
  blob: Blob;
  createdAt: number;
}

class WaypointDB extends Dexie {
  trips!: EntityTable<Trip, 'id'>;
  itineraryItems!: EntityTable<ItineraryItem, 'id'>;
  packingItems!: EntityTable<PackingItem, 'id'>;
  documents!: EntityTable<TravelDocument, 'id'>;

  constructor() {
    super('waypoint-db');
    this.version(1).stores({
      trips: 'id, startDate, endDate, name',
      itineraryItems: 'id, tripId, start, kind',
      packingItems: 'id, tripId, category',
      documents: 'id, tripId, category',
    });
  }
}

export const db = new WaypointDB();

export function newId(): string {
  return crypto.randomUUID();
}

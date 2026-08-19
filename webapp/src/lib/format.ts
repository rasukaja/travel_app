export function formatDateRange(startISO: string, endISO: string): string {
  const start = new Date(startISO);
  const end = new Date(endISO);
  const opts: Intl.DateTimeFormatOptions = { day: '2-digit', month: 'short' };
  const startStr = start.toLocaleDateString('de-DE', opts);
  const endStr = end.toLocaleDateString('de-DE', { ...opts, year: 'numeric' });
  return `${startStr} – ${endStr}`;
}

export function formatDateTime(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleString('de-DE', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function daysUntil(iso: string): number {
  const target = new Date(iso);
  const now = new Date();
  const msPerDay = 1000 * 60 * 60 * 24;
  return Math.ceil((target.getTime() - now.getTime()) / msPerDay);
}

export const KIND_LABELS: Record<string, string> = {
  flight: 'Flug',
  hotel: 'Hotel',
  activity: 'Aktivität',
  note: 'Notiz',
};

export const KIND_EMOJI: Record<string, string> = {
  flight: '✈️',
  hotel: '🏨',
  activity: '📍',
  note: '📝',
};

export const DOCUMENT_CATEGORY_LABELS: Record<string, string> = {
  passport: 'Ausweis/Pass',
  ticket: 'Ticket',
  confirmation: 'Buchungsbestätigung',
  other: 'Sonstiges',
};

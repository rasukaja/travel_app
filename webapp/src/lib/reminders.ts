import type { ItineraryItem } from '../db/db';

/**
 * iOS PWA limitation: real background push needs a push server we don't
 * have, so background notifications while the app is closed are not
 * reliable on iOS. What we *can* do reliably:
 *  - surface "starting soon" items whenever the app is opened/foregrounded
 *  - fire a foreground Notification (if permission granted) for items
 *    starting within the next few hours, while the tab/app is open
 */

export const REMINDER_WINDOW_HOURS = 36;

export function itemsStartingSoon(items: ItineraryItem[], now = new Date()): ItineraryItem[] {
  const windowMs = REMINDER_WINDOW_HOURS * 60 * 60 * 1000;
  return items
    .filter((item) => {
      const start = new Date(item.start).getTime();
      const diff = start - now.getTime();
      return diff >= -1000 * 60 * 60 && diff <= windowMs; // include just-started items
    })
    .sort((a, b) => new Date(a.start).getTime() - new Date(b.start).getTime());
}

export async function requestNotificationPermission(): Promise<NotificationPermission | 'unsupported'> {
  if (!('Notification' in window)) return 'unsupported';
  if (Notification.permission === 'default') {
    return Notification.requestPermission();
  }
  return Notification.permission;
}

export function notifyIfPossible(title: string, body: string) {
  if (!('Notification' in window)) return;
  if (Notification.permission !== 'granted') return;
  try {
    new Notification(title, { body, icon: '/pwa-192x192.png' });
  } catch {
    // Some browsers require a service worker registration to show
    // notifications; fail silently and rely on the in-app banner instead.
  }
}

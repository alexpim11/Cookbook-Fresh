/* My CookBook — service worker.
 * Caches the app shell so it works offline once installed.
 * Bump CACHE_VERSION whenever you change the HTML and want users to get the update.
 */
const CACHE_VERSION = 'cookbook-v26-spoonacular-meal-plans';
const ASSETS = [
  './',
  './cookbook-fresh.html',
  './manifest.json',
  './firebase-config.js',
  './spoonacular-config.js',
  './ai-config.js',
  './icons/icon-120.png',
  './icons/icon-152.png',
  './icons/icon-167.png',
  './icons/icon-180.png',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/favicon-32.png'
];

self.addEventListener('install', e => {
  // Cache the app shell immediately on install.
  // addAll() rejects the whole install if any one file 404s, so each asset is
  // fetched on its own — a missing icon shouldn't stop the app working offline.
  e.waitUntil(
    caches.open(CACHE_VERSION)
      .then(c => Promise.all(ASSETS.map(a => c.add(a).catch(() => {}))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  // Clean up old caches when a new SW takes over.
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE_VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  // Only handle GET requests for our own origin.
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  if (url.origin !== location.origin) return;

  // Network-first for the main HTML so updates are picked up quickly;
  // cache-first for everything else (icons, manifest).
  if (e.request.mode === 'navigate' || url.pathname.endsWith('.html')) {
    e.respondWith(
      fetch(e.request)
        .then(resp => {
          const copy = resp.clone();
          caches.open(CACHE_VERSION).then(c => c.put(e.request, copy));
          return resp;
        })
        .catch(() => caches.match(e.request).then(r => r || caches.match('./cookbook-fresh.html')))
    );
  } else {
    e.respondWith(
      caches.match(e.request).then(cached => cached || fetch(e.request).then(resp => {
        const copy = resp.clone();
        caches.open(CACHE_VERSION).then(c => c.put(e.request, copy));
        return resp;
      }))
    );
  }
});

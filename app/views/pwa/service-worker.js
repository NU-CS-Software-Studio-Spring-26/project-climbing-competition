// Minimal service worker for PWA installability.
// No fetch caching — normal browser and Turbo navigation on desktop stay unchanged.

self.addEventListener("install", (event) => {
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim())
})

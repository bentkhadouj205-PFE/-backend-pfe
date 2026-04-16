/**
 * API root for fetch().
 * - Dev (default): `/api` — Vite proxies to the backend (see vite.config.ts).
 * - Override: set `VITE_API_URL` in `.env` (e.g. `http://127.0.0.1:5000/api`).
 */
const raw = import.meta.env.VITE_API_URL as string | undefined;
export const API_BASE_URL = (raw?.trim() ? raw.trim() : '/api').replace(/\/$/, '');

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository structure

This is an orchestrator repo for "GóndolaPro" (a supermarket expiration/shrinkage monitoring system), composed of two git submodules plus DB bootstrap:

```
Proyecto-Deploy-main/
├── docker-compose.yml        ← orchestrates db, db-init, backend, frontend
├── init.sql                  ← full schema + seed data for SQL Server (regenerated from SSMS, not hand-edited)
├── backend/                  ← submodule: Node/Express API (github.com/Albano107/Proyecto-Backend)
└── frontend/                 ← submodule: React/Vite SPA (github.com/Albano107/Proyecto-Front)
```

Each submodule has its own git history/remote. When editing backend or frontend code, `cd` into the respective submodule directory first — commits made there belong to that submodule's repo, not this orchestrator repo.

## Commands

### Full stack (from repo root)
```bash
docker-compose up --build        # build + start db, db-init, backend, frontend
docker-compose up --build -d     # same, detached
docker-compose logs -f [backend|frontend|db]
docker-compose down              # stop, keep DB volume
docker-compose down -v           # stop and wipe DB volume (re-runs init.sql fresh next start)
docker-compose up --build backend   # rebuild/restart a single service
```
Default URLs: frontend `http://localhost`, backend `http://localhost:3001` (mapped from container port 3000), SQL Server `localhost:1433`.
Default seeded admin login: `admin@gondola.com` / password `1234` / PIN `0000`.

### Backend (`backend/`)
```bash
npm install
npm run dev       # nodemon src/server.js
npm start         # node src/server.js
```
No lint/test scripts are defined in this submodule.

Requires a `.env` (not committed) with `PORT`, `DB_SERVER`, `DB_PORT`, `DB_DATABASE`, `DB_USER`, `DB_PASSWORD`, `JWT_SECRET` — see the values docker-compose injects for the containerized DB.

### Frontend (`frontend/`)
```bash
npm install
npm run dev        # vite dev server
npm run build       # vite build
npm run lint        # eslint .
npm run preview
```
No test scripts are defined in this submodule.

## Architecture

### Backend: plain layered Express app
`src/server.js` calls `connectDB()` (retries 5x with 5s backoff, exits process on final failure) then starts `app.js`. `app.js` wires one router per resource under a fixed prefix: `/auth`, `/productos`, `/inventario`, `/dashboard`, `/usuarios`, `/retiros`, `/sucursales`. Each resource follows `routes/*.routes.js` → `controllers/*.controller.js` → raw `mssql` queries via the shared `src/config/db.js` connection (no ORM/query builder, no repository layer).

**No auth/authorization is actually enforced server-side.** `src/middlewares/auth.middleware.js`, `role.middleware.js`, and `src/utils/helpers.js` exist but are empty and unused — no route imports them. `auth.controller.js` does a plaintext password comparison directly against the `Usuarios` table (no bcrypt/JWT despite those packages being installed and mentioned in the README) and returns the user row (including `rol` and `id_sucursal`) as the "session". The frontend stores this in state/localStorage and does its own client-side role gating (see below) — there is no server-side check preventing a non-admin client from calling any endpoint. Treat the backend README's description of JWT auth as aspirational/stale, not current behavior.

**SQL parameterization is inconsistent.** Some queries use `mssql`'s tagged-template `sql.query\`...${var}\`` (auto-parameterized), but others build query strings via plain interpolation (e.g. `obtenerInventario`'s `whereClause`, `armarFiltroSucursal` in retiros, `cambiarEstadoUsuario`). Numeric inputs are validated with `parseInt`/`Number.isNaN` before interpolation in most of these spots — check for that guard before assuming a query is safe, and prefer the tagged-template form for any new query.

`services/semaforo.service.js` (`calcularEstado`) is the single source of truth for the traffic-light logic: given `fecha_vencimiento` and a department's `dias_alerta`, returns `ROJO` (already expired), `AMARILLO` (within alert window), or `VERDE`. It's used both by `inventario.controller.js` (per-row) and `dashboard.controller.js` (aggregate counts) — SQL-side aggregate queries (e.g. the `resumen` block in `obtenerInventario`) reimplement the same threshold logic in raw `DATEDIFF` CASE expressions, so if the alert-window rule changes, update both the JS function and these SQL CASE blocks.

`inventario.controller.js`'s `obtenerInventario` has two response shapes depending on whether `page`/`limit` query params are present: without them it returns a bare array (legacy behavior, kept for compatibility); with them it returns `{ datos, pagina, limite, total, totalPaginas, resumen }`.

### Frontend: single-file state machine, no router
`App.jsx` holds `pagina` (string) and `usuario` (the login response object) in `useState` and renders one of `Login`/`Inicio`/`Inventario`/`Reportes`/`Usuarios` based on `pagina` — there is no `react-router`, navigation is done by passing an `onNavegar(pagina)` callback down as a prop. Each page component receives `usuario` and re-derives role/branch-scoped behavior from it directly (e.g. `usuario?.rol === "Operario"` hides admin-only nav items and cross-branch (`id_sucursal`) data in `inicio.jsx`, `inventario.jsx`, `reportes.jsx`) — this is UI-only gating, not a security boundary (see backend note above).

API calls go through `src/api/axios.js`, an axios instance with `baseURL: "/api"` that auto-attaches `Authorization: Bearer <token>` from `localStorage.getItem("token")` on every request — note the backend doesn't currently issue or check any such token, so this is currently a no-op placeholder for when JWT is wired up. `src/api/auth.js` wraps the two `/auth` endpoints (`login`, `login-pin`); other pages import `../api/axios` directly rather than a dedicated api module per resource.

In dev (`vite`), API requests to `/api` need a proxy or will 404 — the `/api` prefix is stripped by nginx (`nginx.conf`) only in the built/Dockerized frontend, which proxies `/api/` → `http://backend:3000/`. Check `vite.config.js` before assuming `npm run dev` can talk to a local backend out of the box.

`inventario.jsx` integrates `html5-qrcode`'s `Html5Qrcode` for barcode scanning; it's the only page using that library.

Styling is plain CSS per page (`pages/*.css`), no CSS framework despite `tailwindcss`/`postcss` being present in `package.json`/`tailwind.config.js` — check whether Tailwind classes are actually used before assuming the styling approach for a given file.

### Database
`init.sql` creates and seeds SQL Server tables: `Roles`, `Departamentos`, `Sucursales`, `Usuarios`, `Productos`, `Inventario`, `Retiros`. It's a full SSMS-generated dump (schema + data), meant to be regenerated wholesale and replaced — see the root `README.md`'s "Cómo actualizar los datos de la base de datos" section for the SSMS export workflow. Don't hand-edit it piecemeal; if you need a schema change, coordinate it with a regenerated dump so schema and seed data stay in sync. Note `Inventario` and `Retiros` are branch-scoped via `id_sucursal`/join chains, and `dias_alerta` (the semaforo threshold) lives on `Departamentos`, not per-product.

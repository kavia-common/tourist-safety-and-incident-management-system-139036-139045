# Demo Data Seeding Guide

This folder contains a SQL script to populate realistic dummy data into the PostgreSQL database for the Smart Tourist Safety & Incident Response demo.

What gets inserted:
- Tourists (3), multi-language name entry
- Digital IDs (1 active per tourist)
- Itineraries (Paris, NYC, Tokyo trips)
- Alerts (panic, geofence, anomaly, device, system)
- Safety scores (computed with contextual factors)
- AI events (linked to alerts)
- IoT devices and events (smartwatch/bracelet)
- Dashboard metrics (KPIs)

Prerequisites:
- PostgreSQL running locally, created via provided scripts.
- The database connection details are already written to `db_connection.txt` by `startup.sh`.
- The schema is present (e.g., loaded by `restore_db.sh` or initial startup flow).

How to load the data:
1) Start or verify Postgres:
   - ./startup.sh

2) Connect and load using the exact CLI provided in db_connection.txt:
   - (Option A) Copy-paste:
     psql postgresql://appuser:dbuser123@localhost:5000/myapp -f seed_demo_data.sql

   - (Option B) Using the file directly:
     $(cat db_connection.txt) -f seed_demo_data.sql

3) Verify with the simple DB viewer (optional):
   - source db_visualizer/postgres.env
   - node db_visualizer/server.js
   - GET http://localhost:3000/api/postgres/tables
   - GET http://localhost:3000/api/postgres/tables/alert_logs/data?limit=50

Notes:
- Inserts are performed one row per statement for safety.
- Re-running the script will add additional rows except where unique constraints apply (e.g., dashboard_metrics unique by metric_date, metric_key, scope).
- If you need to re-run for the same day, you may want to purge today’s metrics first:
  DELETE FROM public.dashboard_metrics WHERE metric_date = current_date;

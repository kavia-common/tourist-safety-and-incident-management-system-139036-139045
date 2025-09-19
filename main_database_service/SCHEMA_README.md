# Smart Tourist Safety Monitoring DB Schema (PostgreSQL)

This document summarizes the PostgreSQL schema created via CLI for the Smart Tourist Safety Monitoring & Incident Response System.

Notes:
- PostGIS is not available in this environment, so geospatial data is stored as latitude/longitude with supporting indexes.
- UUIDs are generated using pgcrypto's gen_random_uuid().
- JSONB is used for flexible metadata where appropriate.
- Partial/functional unique indexes are used to enforce business rules.

Extensions
- pgcrypto (for gen_random_uuid())

Enums
- alert_severity: low | medium | high | critical
- alert_type: panic | geofence_breach | anomaly | device | system
- language_code: en | es | fr | de | zh | hi | ar | ru | pt | ja | ko

Core Tables

1) tourists
- id UUID PK DEFAULT gen_random_uuid()
- created_at TIMESTAMPTZ DEFAULT now()
- updated_at TIMESTAMPTZ DEFAULT now()
- first_name TEXT NOT NULL
- last_name TEXT NOT NULL
- date_of_birth DATE
- country_of_origin TEXT
- passport_number TEXT
- national_id TEXT
- phone TEXT
- email TEXT
- preferred_language language_code DEFAULT 'en'
- consent_data_processing BOOLEAN DEFAULT true
- consent_location_tracking BOOLEAN DEFAULT false

2) languages
- code language_code PK
- name TEXT NOT NULL

3) tourist_names_i18n
- id BIGSERIAL PK
- tourist_id UUID FK -> tourists(id) ON DELETE CASCADE
- language language_code NOT NULL
- full_name TEXT NOT NULL
- UNIQUE (tourist_id, language)

Digital Identity

4) digital_ids
- id UUID PK DEFAULT gen_random_uuid()
- tourist_id UUID NOT NULL FK -> tourists(id) ON DELETE CASCADE
- blockchain_tx_hash TEXT
- public_key TEXT
- hash_algorithm TEXT DEFAULT 'SHA256'
- id_hash TEXT NOT NULL
- issued_at TIMESTAMPTZ DEFAULT now()
- revoked_at TIMESTAMPTZ
- is_active BOOLEAN DEFAULT true
Indexes:
- uq_digital_ids_active_per_tourist: UNIQUE (tourist_id) WHERE is_active

Itineraries

5) itineraries
- id UUID PK DEFAULT gen_random_uuid()
- tourist_id UUID NOT NULL FK -> tourists(id) ON DELETE CASCADE
- start_date DATE NOT NULL
- end_date DATE
- origin_country TEXT
- destination_country TEXT
- origin_city TEXT
- destination_city TEXT
- travel_mode TEXT
- booking_ref TEXT
- notes TEXT
- created_at TIMESTAMPTZ DEFAULT now()

Alerts

6) alert_logs
- id UUID PK DEFAULT gen_random_uuid()
- tourist_id UUID NULL FK -> tourists(id) ON DELETE SET NULL
- itinerary_id UUID NULL FK -> itineraries(id) ON DELETE SET NULL
- alert_time TIMESTAMPTZ DEFAULT now()
- latitude DOUBLE PRECISION
- longitude DOUBLE PRECISION
- geohash TEXT
- alert_type alert_type NOT NULL
- severity alert_severity NOT NULL DEFAULT 'low'
- message TEXT
- metadata JSONB DEFAULT '{}'
Indexes:
- idx_alert_logs_time (alert_time DESC)
- idx_alert_logs_geo (latitude, longitude)

Safety Scores

7) safety_scores
- id UUID PK DEFAULT gen_random_uuid()
- tourist_id UUID NOT NULL FK -> tourists(id) ON DELETE CASCADE
- related_alert_id UUID NULL FK -> alert_logs(id) ON DELETE SET NULL
- score NUMERIC(5,2) NOT NULL CHECK 0 <= score <= 100
- computed_at TIMESTAMPTZ DEFAULT now()
- factors JSONB DEFAULT '{}'

AI Events

8) ai_events
- id UUID PK DEFAULT gen_random_uuid()
- event_time TIMESTAMPTZ DEFAULT now()
- tourist_id UUID NULL FK -> tourists(id) ON DELETE SET NULL
- source TEXT NOT NULL
- model TEXT
- confidence NUMERIC(5,2)
- event_type TEXT NOT NULL
- description TEXT
- features JSONB DEFAULT '{}'
- related_alert_id UUID NULL FK -> alert_logs(id) ON DELETE SET NULL
Indexes:
- idx_ai_events_time (event_time DESC)

IoT

9) iot_devices
- id UUID PK DEFAULT gen_random_uuid()
- device_id TEXT UNIQUE NOT NULL
- device_type TEXT
- owner_tourist_id UUID NULL FK -> tourists(id) ON DELETE SET NULL
- registered_at TIMESTAMPTZ DEFAULT now()
- last_seen TIMESTAMPTZ

10) iot_events
- id UUID PK DEFAULT gen_random_uuid()
- device_id UUID NULL FK -> iot_devices(id) ON DELETE SET NULL
- tourist_id UUID NULL FK -> tourists(id) ON DELETE SET NULL
- event_time TIMESTAMPTZ DEFAULT now()
- latitude DOUBLE PRECISION
- longitude DOUBLE PRECISION
- geohash TEXT
- payload JSONB NOT NULL
- event_type TEXT
- related_alert_id UUID NULL FK -> alert_logs(id) ON DELETE SET NULL
Indexes:
- idx_iot_events_time (event_time DESC)

Dashboard Metrics

11) dashboard_metrics
- id BIGSERIAL PK
- metric_date DATE NOT NULL
- metric_key TEXT NOT NULL
- metric_value NUMERIC
- dimensions JSONB DEFAULT '{}'
- created_at TIMESTAMPTZ DEFAULT now()
Indexes:
- uq_dashboard_metrics_key: UNIQUE (metric_date, metric_key, COALESCE(dimensions->>'scope','global'))

Integration Notes (main_backend_service)
- Prefer joins on UUID FKs (tourist_id, related_alert_id, itinerary_id).
- Use JSONB containment/operators for metadata queries.
- For geospatial proximity without PostGIS, filter on bounding boxes with latitude/longitude and refine by Haversine in application layer if needed.
- Use partial and functional indexes as created above for performance and uniqueness rules.


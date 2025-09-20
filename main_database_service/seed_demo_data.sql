-- Smart Tourist Safety Monitoring & Incident Response System
-- Demo seed data (PostgreSQL)
-- Notes:
-- - One row per INSERT for safety as requested.
-- - Uses gen_random_uuid() for IDs and returns captured via CTEs for FK wiring.
-- - Keep realistic timestamps and lat/lng around popular destinations.
-- - Safe dummy data only.

-- Ensure required enums and tables exist (assumes database_backup.sql already created them)
-- This script only inserts data.

-- Languages (basic set)
INSERT INTO public.languages(code, name) VALUES ('en', 'English') ON CONFLICT DO NOTHING;
INSERT INTO public.languages(code, name) VALUES ('es', 'Spanish') ON CONFLICT DO NOTHING;
INSERT INTO public.languages(code, name) VALUES ('fr', 'French') ON CONFLICT DO NOTHING;
INSERT INTO public.languages(code, name) VALUES ('de', 'German') ON CONFLICT DO NOTHING;
INSERT INTO public.languages(code, name) VALUES ('zh', 'Chinese') ON CONFLICT DO NOTHING;

-- Tourists
WITH t AS (
  INSERT INTO public.tourists (
    id, created_at, updated_at, first_name, last_name, date_of_birth, country_of_origin,
    passport_number, national_id, phone, email, preferred_language,
    consent_data_processing, consent_location_tracking
  ) VALUES (
    gen_random_uuid(), now(), now(), 'Alice', 'Nguyen', '1990-05-12', 'Vietnam',
    'P12345678', 'VN-19900512-001', '+84-912-345-678', 'alice.nguyen@example.com', 'en', true, true
  )
  RETURNING id
)
INSERT INTO public.tourist_names_i18n (tourist_id, language, full_name)
SELECT id, 'en', 'Alice Nguyen' FROM t;

WITH t AS (
  INSERT INTO public.tourists (
    id, created_at, updated_at, first_name, last_name, date_of_birth, country_of_origin,
    passport_number, national_id, phone, email, preferred_language,
    consent_data_processing, consent_location_tracking
  ) VALUES (
    gen_random_uuid(), now(), now(), 'Carlos', 'Diaz', '1985-10-03', 'Spain',
    'XK9876543', 'ES-19851003-002', '+34-600-111-222', 'carlos.diaz@example.com', 'es', true, false
  )
  RETURNING id
)
INSERT INTO public.tourist_names_i18n (tourist_id, language, full_name)
SELECT id, 'es', 'Carlos Díaz' FROM t;

WITH t AS (
  INSERT INTO public.tourists (
    id, created_at, updated_at, first_name, last_name, date_of_birth, country_of_origin,
    passport_number, national_id, phone, email, preferred_language,
    consent_data_processing, consent_location_tracking
  ) VALUES (
    gen_random_uuid(), now(), now(), 'Sofia', 'Khan', '1994-03-22', 'Pakistan',
    'PK4455667', 'PK-19940322-003', '+92-300-555-777', 'sofia.khan@example.com', 'en', true, true
  )
  RETURNING id
)
INSERT INTO public.tourist_names_i18n (tourist_id, language, full_name)
SELECT id, 'en', 'Sofia Khan' FROM t;

-- Active digital IDs (1 active per tourist rule)
WITH t AS (SELECT id FROM public.tourists WHERE email='alice.nguyen@example.com' LIMIT 1)
INSERT INTO public.digital_ids (tourist_id, blockchain_tx_hash, public_key, id_hash, is_active)
SELECT id, '0xabcde12345fakelight', 'ALICE_PUB_KEY', digest('Alice Nguyen|P12345678','sha256')::text, true FROM t;

WITH t AS (SELECT id FROM public.tourists WHERE email='carlos.diaz@example.com' LIMIT 1)
INSERT INTO public.digital_ids (tourist_id, blockchain_tx_hash, public_key, id_hash, is_active)
SELECT id, '0x98765faketxhash', 'CARLOS_PUB_KEY', digest('Carlos Diaz|XK9876543','sha256')::text, true FROM t;

WITH t AS (SELECT id FROM public.tourists WHERE email='sofia.khan@example.com' LIMIT 1)
INSERT INTO public.digital_ids (tourist_id, blockchain_tx_hash, public_key, id_hash, is_active)
SELECT id, '0x55555faketx', 'SOFIA_PUB_KEY', digest('Sofia Khan|PK4455667','sha256')::text, true FROM t;

-- Itineraries
-- Alice: Paris trip
WITH t AS (SELECT id AS tourist_id FROM public.tourists WHERE email='alice.nguyen@example.com' LIMIT 1)
INSERT INTO public.itineraries (tourist_id, start_date, end_date, origin_country, destination_country, origin_city, destination_city, travel_mode, booking_ref, notes)
SELECT tourist_id, current_date - INTERVAL '3 days', current_date + INTERVAL '2 days', 'Vietnam', 'France', 'Hanoi', 'Paris', 'flight', 'ALC-PAR-2025-01', 'City tour, Louvre, Eiffel' FROM t;

-- Carlos: NYC visit
WITH t AS (SELECT id AS tourist_id FROM public.tourists WHERE email='carlos.diaz@example.com' LIMIT 1)
INSERT INTO public.itineraries (tourist_id, start_date, end_date, origin_country, destination_country, origin_city, destination_city, travel_mode, booking_ref, notes)
SELECT tourist_id, current_date - INTERVAL '1 days', current_date + INTERVAL '6 days', 'Spain', 'USA', 'Madrid', 'New York', 'flight', 'CRL-NYC-2025-02', 'Broadway, Central Park, MoMA' FROM t;

-- Sofia: Tokyo tour
WITH t AS (SELECT id AS tourist_id FROM public.tourists WHERE email='sofia.khan@example.com' LIMIT 1)
INSERT INTO public.itineraries (tourist_id, start_date, end_date, origin_country, destination_country, origin_city, destination_city, travel_mode, booking_ref, notes)
SELECT tourist_id, current_date - INTERVAL '2 days', current_date + INTERVAL '4 days', 'Pakistan', 'Japan', 'Karachi', 'Tokyo', 'flight', 'SF-TYO-2025-03', 'Shinjuku, Shibuya, Akihabara' FROM t;

-- IoT Devices (wearables) bound to tourists
WITH t AS (SELECT id FROM public.tourists WHERE email='alice.nguyen@example.com' LIMIT 1)
INSERT INTO public.iot_devices (device_id, device_type, owner_tourist_id, last_seen)
SELECT 'WTCH-ALC-001', 'smartwatch', id, now() - INTERVAL '10 minutes' FROM t;

WITH t AS (SELECT id FROM public.tourists WHERE email='carlos.diaz@example.com' LIMIT 1)
INSERT INTO public.iot_devices (device_id, device_type, owner_tourist_id, last_seen)
SELECT 'BRCL-CRL-009', 'bracelet', id, now() - INTERVAL '20 minutes' FROM t;

-- ALERTS
-- Alice panic near Eiffel Tower (Paris: 48.8584, 2.2945)
WITH t AS (
  SELECT tr.id AS tourist_id,
         (SELECT it.id FROM public.itineraries it WHERE it.tourist_id = tr.id ORDER BY created_at DESC LIMIT 1) AS itinerary_id
  FROM public.tourists tr WHERE tr.email='alice.nguyen@example.com' LIMIT 1
)
INSERT INTO public.alert_logs (tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata)
SELECT tourist_id, itinerary_id, now() - INTERVAL '5 minutes', 48.8584, 2.2945, NULL, 'panic', 'high',
       'SOS triggered via app near Eiffel Tower',
       jsonb_build_object('source','mobile','battery','58%','network','4G','accuracy','high')
FROM t;

-- Carlos geofence breach near Times Square (NYC: 40.7580, -73.9855)
WITH t AS (
  SELECT tr.id AS tourist_id,
         (SELECT it.id FROM public.itineraries it WHERE it.tourist_id = tr.id ORDER BY created_at DESC LIMIT 1) AS itinerary_id
  FROM public.tourists tr WHERE tr.email='carlos.diaz@example.com' LIMIT 1
)
INSERT INTO public.alert_logs (tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata)
SELECT tourist_id, itinerary_id, now() - INTERVAL '30 minutes', 40.7580, -73.9855, NULL, 'geofence_breach', 'medium',
       'Exited safe zone near Times Square',
       jsonb_build_object('geofence','Midtown-Safe-Zone','action','notify','radius_m',300)
FROM t;

-- Sofia anomaly by AI near Shibuya Crossing (Tokyo: 35.6595, 139.7005)
WITH t AS (
  SELECT tr.id AS tourist_id,
         (SELECT it.id FROM public.itineraries it WHERE it.tourist_id = tr.id ORDER BY created_at DESC LIMIT 1) AS itinerary_id
  FROM public.tourists tr WHERE tr.email='sofia.khan@example.com' LIMIT 1
)
INSERT INTO public.alert_logs (tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata)
SELECT tourist_id, itinerary_id, now() - INTERVAL '90 minutes', 35.6595, 139.7005, NULL, 'anomaly', 'low',
       'Unusual dwell time detected near Shibuya Crossing',
       jsonb_build_object('model','movement-anomaly-v2','threshold','0.82','window_min',30)
FROM t;

-- AI Events tied to alerts
WITH a AS (
  SELECT id AS alert_id, tourist_id
  FROM public.alert_logs
  WHERE message LIKE 'SOS triggered via app near Eiffel Tower'
  LIMIT 1
)
INSERT INTO public.ai_events (event_time, tourist_id, source, model, confidence, event_type, description, features, related_alert_id)
SELECT now() - INTERVAL '4 minutes',
       tourist_id,
       'vision-guardian',
       'yolo-v8-panic-detection',
       96.5,
       'panic_detection',
       'Detected distress posture and waving',
       jsonb_build_object('frames','12','bbox_count',3,'avg_light','0.72'),
       alert_id
FROM a;

WITH a AS (
  SELECT id AS alert_id, tourist_id
  FROM public.alert_logs
  WHERE message LIKE 'Exited safe zone near Times Square'
  LIMIT 1
)
INSERT INTO public.ai_events (event_time, tourist_id, source, model, confidence, event_type, description, features, related_alert_id)
SELECT now() - INTERVAL '28 minutes',
       tourist_id,
       'geofence-engine',
       'point-in-polygon-v1',
       88.2,
       'geofence_exit',
       'Crossed boundary of Midtown-Safe-Zone',
       jsonb_build_object('distance_m',45,'speed_kmh',3.5),
       alert_id
FROM a;

-- IoT Events linked to devices and alerts
-- Find device and tourist for Alice
WITH d AS (
  SELECT dev.id AS device_pk, dev.device_id, tr.id AS tourist_id
  FROM public.iot_devices dev
  JOIN public.tourists tr ON tr.id = dev.owner_tourist_id
  WHERE dev.device_id='WTCH-ALC-001' LIMIT 1
)
INSERT INTO public.iot_events (device_id, tourist_id, event_time, latitude, longitude, geohash, payload, event_type, related_alert_id)
SELECT device_pk, tourist_id, now() - INTERVAL '6 minutes', 48.8584, 2.2945, NULL,
       jsonb_build_object('hr',122,'accel','high','fall_detected',true),
       'fall_detect',
       (SELECT id FROM public.alert_logs WHERE message LIKE 'SOS triggered via app near Eiffel Tower' LIMIT 1)
FROM d;

-- Carlos smartwatch steps near Times Square
WITH d AS (
  SELECT dev.id AS device_pk, dev.device_id, tr.id AS tourist_id
  FROM public.iot_devices dev
  JOIN public.tourists tr ON tr.id = dev.owner_tourist_id
  WHERE dev.device_id='BRCL-CRL-009' LIMIT 1
)
INSERT INTO public.iot_events (device_id, tourist_id, event_time, latitude, longitude, geohash, payload, event_type, related_alert_id)
SELECT device_pk, tourist_id, now() - INTERVAL '35 minutes', 40.7580, -73.9855, NULL,
       jsonb_build_object('steps',312,'battery','81%'),
       'activity',
       (SELECT id FROM public.alert_logs WHERE message LIKE 'Exited safe zone near Times Square' LIMIT 1)
FROM d;

-- Safety Scores (computed)
WITH t AS (SELECT id FROM public.tourists WHERE email='alice.nguyen@example.com' LIMIT 1)
INSERT INTO public.safety_scores (tourist_id, related_alert_id, score, factors)
SELECT id,
       (SELECT id FROM public.alert_logs WHERE message LIKE 'SOS triggered via app near Eiffel Tower' LIMIT 1),
       62.50,
       jsonb_build_object('panic_recent',true,'fall_detected',true,'location_risk','moderate')
FROM t;

WITH t AS (SELECT id FROM public.tourists WHERE email='carlos.diaz@example.com' LIMIT 1)
INSERT INTO public.safety_scores (tourist_id, related_alert_id, score, factors)
SELECT id,
       (SELECT id FROM public.alert_logs WHERE message LIKE 'Exited safe zone near Times Square' LIMIT 1),
       78.20,
       jsonb_build_object('geofence_exit',true,'time_of_day','evening','crowd_density','high')
FROM t;

WITH t AS (SELECT id FROM public.tourists WHERE email='sofia.khan@example.com' LIMIT 1)
INSERT INTO public.safety_scores (tourist_id, related_alert_id, score, factors)
SELECT id,
       (SELECT id FROM public.alert_logs WHERE message LIKE 'Unusual dwell time detected near Shibuya Crossing' LIMIT 1),
       84.10,
       jsonb_build_object('anomaly_score',0.82,'area','tourist_hotspot')
FROM t;

-- Dashboard Metrics (sample KPI snapshots)
-- Note: metrics use metric_date granularity. Scope dimension in JSONB.
INSERT INTO public.dashboard_metrics (metric_date, metric_key, metric_value, dimensions)
VALUES (current_date, 'active_tourists', 3, jsonb_build_object('scope','global'));

INSERT INTO public.dashboard_metrics (metric_date, metric_key, metric_value, dimensions)
VALUES (current_date, 'alerts_last_24h', 7, jsonb_build_object('scope','global'));

INSERT INTO public.dashboard_metrics (metric_date, metric_key, metric_value, dimensions)
VALUES (current_date, 'avg_response_time_sec', 128, jsonb_build_object('scope','authority','region','Paris'));

INSERT INTO public.dashboard_metrics (metric_date, metric_key, metric_value, dimensions)
VALUES (current_date, 'panic_events', 1, jsonb_build_object('scope','global'));

INSERT INTO public.dashboard_metrics (metric_date, metric_key, metric_value, dimensions)
VALUES (current_date, 'iot_messages_last_hour', 42, jsonb_build_object('scope','global'));

-- Additional alerts to enrich streams (system/device)
-- Device health warning for Carlos
WITH t AS (
  SELECT tr.id AS tourist_id,
         (SELECT it.id FROM public.itineraries it WHERE it.tourist_id = tr.id ORDER BY created_at DESC LIMIT 1) AS itinerary_id
  FROM public.tourists tr WHERE tr.email='carlos.diaz@example.com' LIMIT 1
)
INSERT INTO public.alert_logs (tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata)
SELECT tourist_id, itinerary_id, now() - INTERVAL '50 minutes', 40.7580, -73.9855, NULL, 'device', 'low',
       'Wearable battery low: 15%',
       jsonb_build_object('device_id','BRCL-CRL-009','battery','15%')
FROM t;

-- System notice
INSERT INTO public.alert_logs (tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata)
VALUES (NULL, NULL, now() - INTERVAL '2 hours', NULL, NULL, NULL, 'system', 'low',
        'System maintenance window scheduled at 02:00 UTC',
        jsonb_build_object('window_minutes',30,'impact','minimal'));

-- Usage:
-- 1) Ensure PostgreSQL is running (use startup.sh if needed).
-- 2) Connect as per db_connection.txt or run the command below:
--    psql postgresql://appuser:dbuser123@localhost:5000/myapp -f seed_demo_data.sql
-- 3) You can re-run safely; metric unique index may conflict if same scope/key/date is inserted twice.
--    If re-running often, consider deleting from dashboard_metrics for current_date first.

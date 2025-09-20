--
-- PostgreSQL database dump
--

\restrict auiNlK1L6BVr85KTXexfleWCQwe31NzlUGxGH3dvCUnrrXUog0IkpD4I4JS8qgo

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO postgres;

\unrestrict auiNlK1L6BVr85KTXexfleWCQwe31NzlUGxGH3dvCUnrrXUog0IkpD4I4JS8qgo
\connect myapp
\restrict auiNlK1L6BVr85KTXexfleWCQwe31NzlUGxGH3dvCUnrrXUog0IkpD4I4JS8qgo

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: alert_severity; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.alert_severity AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE public.alert_severity OWNER TO appuser;

--
-- Name: alert_type; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.alert_type AS ENUM (
    'panic',
    'geofence_breach',
    'anomaly',
    'device',
    'system'
);


ALTER TYPE public.alert_type OWNER TO appuser;

--
-- Name: language_code; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.language_code AS ENUM (
    'en',
    'es',
    'fr',
    'de',
    'zh',
    'hi',
    'ar',
    'ru',
    'pt',
    'ja',
    'ko'
);


ALTER TYPE public.language_code OWNER TO appuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_events; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.ai_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_time timestamp with time zone DEFAULT now(),
    tourist_id uuid,
    source text NOT NULL,
    model text,
    confidence numeric(5,2),
    event_type text NOT NULL,
    description text,
    features jsonb DEFAULT '{}'::jsonb,
    related_alert_id uuid
);


ALTER TABLE public.ai_events OWNER TO appuser;

--
-- Name: alert_logs; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.alert_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tourist_id uuid,
    itinerary_id uuid,
    alert_time timestamp with time zone DEFAULT now(),
    latitude double precision,
    longitude double precision,
    geohash text,
    alert_type public.alert_type NOT NULL,
    severity public.alert_severity DEFAULT 'low'::public.alert_severity NOT NULL,
    message text,
    metadata jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.alert_logs OWNER TO appuser;

--
-- Name: dashboard_metrics; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.dashboard_metrics (
    id bigint NOT NULL,
    metric_date date NOT NULL,
    metric_key text NOT NULL,
    metric_value numeric,
    dimensions jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.dashboard_metrics OWNER TO appuser;

--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: appuser
--

CREATE SEQUENCE public.dashboard_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dashboard_metrics_id_seq OWNER TO appuser;

--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: appuser
--

ALTER SEQUENCE public.dashboard_metrics_id_seq OWNED BY public.dashboard_metrics.id;


--
-- Name: digital_ids; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.digital_ids (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tourist_id uuid NOT NULL,
    blockchain_tx_hash text,
    public_key text,
    hash_algorithm text DEFAULT 'SHA256'::text,
    id_hash text NOT NULL,
    issued_at timestamp with time zone DEFAULT now(),
    revoked_at timestamp with time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.digital_ids OWNER TO appuser;

--
-- Name: iot_devices; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.iot_devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_id text NOT NULL,
    device_type text,
    owner_tourist_id uuid,
    registered_at timestamp with time zone DEFAULT now(),
    last_seen timestamp with time zone
);


ALTER TABLE public.iot_devices OWNER TO appuser;

--
-- Name: iot_events; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.iot_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_id uuid,
    tourist_id uuid,
    event_time timestamp with time zone DEFAULT now(),
    latitude double precision,
    longitude double precision,
    geohash text,
    payload jsonb NOT NULL,
    event_type text,
    related_alert_id uuid
);


ALTER TABLE public.iot_events OWNER TO appuser;

--
-- Name: itineraries; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.itineraries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tourist_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date,
    origin_country text,
    destination_country text,
    origin_city text,
    destination_city text,
    travel_mode text,
    booking_ref text,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.itineraries OWNER TO appuser;

--
-- Name: languages; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.languages (
    code public.language_code NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.languages OWNER TO appuser;

--
-- Name: safety_scores; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.safety_scores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tourist_id uuid NOT NULL,
    related_alert_id uuid,
    score numeric(5,2) NOT NULL,
    computed_at timestamp with time zone DEFAULT now(),
    factors jsonb DEFAULT '{}'::jsonb,
    CONSTRAINT safety_scores_score_check CHECK (((score >= (0)::numeric) AND (score <= (100)::numeric)))
);


ALTER TABLE public.safety_scores OWNER TO appuser;

--
-- Name: tourist_names_i18n; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.tourist_names_i18n (
    id bigint NOT NULL,
    tourist_id uuid,
    language public.language_code NOT NULL,
    full_name text NOT NULL
);


ALTER TABLE public.tourist_names_i18n OWNER TO appuser;

--
-- Name: tourist_names_i18n_id_seq; Type: SEQUENCE; Schema: public; Owner: appuser
--

CREATE SEQUENCE public.tourist_names_i18n_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tourist_names_i18n_id_seq OWNER TO appuser;

--
-- Name: tourist_names_i18n_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: appuser
--

ALTER SEQUENCE public.tourist_names_i18n_id_seq OWNED BY public.tourist_names_i18n.id;


--
-- Name: tourists; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.tourists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    first_name text NOT NULL,
    last_name text NOT NULL,
    date_of_birth date,
    country_of_origin text,
    passport_number text,
    national_id text,
    phone text,
    email text,
    preferred_language public.language_code DEFAULT 'en'::public.language_code,
    consent_data_processing boolean DEFAULT true,
    consent_location_tracking boolean DEFAULT false
);


ALTER TABLE public.tourists OWNER TO appuser;

--
-- Name: dashboard_metrics id; Type: DEFAULT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.dashboard_metrics ALTER COLUMN id SET DEFAULT nextval('public.dashboard_metrics_id_seq'::regclass);


--
-- Name: tourist_names_i18n id; Type: DEFAULT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tourist_names_i18n ALTER COLUMN id SET DEFAULT nextval('public.tourist_names_i18n_id_seq'::regclass);


--
-- Data for Name: ai_events; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.ai_events (id, event_time, tourist_id, source, model, confidence, event_type, description, features, related_alert_id) FROM stdin;
\.


--
-- Data for Name: alert_logs; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.alert_logs (id, tourist_id, itinerary_id, alert_time, latitude, longitude, geohash, alert_type, severity, message, metadata) FROM stdin;
\.


--
-- Data for Name: dashboard_metrics; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.dashboard_metrics (id, metric_date, metric_key, metric_value, dimensions, created_at) FROM stdin;
\.


--
-- Data for Name: digital_ids; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.digital_ids (id, tourist_id, blockchain_tx_hash, public_key, hash_algorithm, id_hash, issued_at, revoked_at, is_active) FROM stdin;
aca63adf-f361-4523-aef5-177f08ae56dd	04c8df52-e6f1-47f6-83c8-2a3c7447918e	0xabcde12345fakelight	ALICE_PUB_KEY	SHA256	\\x1a5b2e3f205ca09950ccf1c7acb5daa6d19b3b9a3c4c23f55e317cd0f3632027	2025-09-20 00:48:26.063983+00	\N	t
c7c92314-5a9e-46e0-b4dd-950fa984b966	80049085-3a42-421e-99e6-f234da317f50	0x98765faketxhash	CARLOS_PUB_KEY	SHA256	\\x2e2a71817258e0433a7e5ffda66341ee93f66e8019c852562d846c46428d113d	2025-09-20 00:48:28.246095+00	\N	t
1b0261b9-3f5e-4b2b-8ab6-79f7069d353e	0c9b6efd-73b5-4a9f-80ab-c6930771b59e	0x55555faketx	SOFIA_PUB_KEY	SHA256	\\x1a1b102a3190fc46170d4c0dabecda6472187bfb7e1f6e680cbde541d9e74e26	2025-09-20 00:48:30.356299+00	\N	t
\.


--
-- Data for Name: iot_devices; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.iot_devices (id, device_id, device_type, owner_tourist_id, registered_at, last_seen) FROM stdin;
\.


--
-- Data for Name: iot_events; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.iot_events (id, device_id, tourist_id, event_time, latitude, longitude, geohash, payload, event_type, related_alert_id) FROM stdin;
\.


--
-- Data for Name: itineraries; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.itineraries (id, tourist_id, start_date, end_date, origin_country, destination_country, origin_city, destination_city, travel_mode, booking_ref, notes, created_at) FROM stdin;
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.languages (code, name) FROM stdin;
en	English
es	Spanish
fr	French
de	German
zh	Chinese
hi	Hindi
ar	Arabic
ru	Russian
pt	Portuguese
ja	Japanese
ko	Korean
\.


--
-- Data for Name: safety_scores; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.safety_scores (id, tourist_id, related_alert_id, score, computed_at, factors) FROM stdin;
\.


--
-- Data for Name: tourist_names_i18n; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.tourist_names_i18n (id, tourist_id, language, full_name) FROM stdin;
1	04c8df52-e6f1-47f6-83c8-2a3c7447918e	en	Alice Nguyen
2	80049085-3a42-421e-99e6-f234da317f50	es	Carlos Díaz
3	0c9b6efd-73b5-4a9f-80ab-c6930771b59e	en	Sofia Khan
\.


--
-- Data for Name: tourists; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.tourists (id, created_at, updated_at, first_name, last_name, date_of_birth, country_of_origin, passport_number, national_id, phone, email, preferred_language, consent_data_processing, consent_location_tracking) FROM stdin;
04c8df52-e6f1-47f6-83c8-2a3c7447918e	2025-09-20 00:48:17.719096+00	2025-09-20 00:48:17.719096+00	Alice	Nguyen	1990-05-12	Vietnam	P12345678	VN-19900512-001	+84-912-345-678	alice.nguyen@example.com	en	t	t
80049085-3a42-421e-99e6-f234da317f50	2025-09-20 00:48:20.48639+00	2025-09-20 00:48:20.48639+00	Carlos	Diaz	1985-10-03	Spain	XK9876543	ES-19851003-002	+34-600-111-222	carlos.diaz@example.com	es	t	f
0c9b6efd-73b5-4a9f-80ab-c6930771b59e	2025-09-20 00:48:23.763279+00	2025-09-20 00:48:23.763279+00	Sofia	Khan	1994-03-22	Pakistan	PK4455667	PK-19940322-003	+92-300-555-777	sofia.khan@example.com	en	t	t
\.


--
-- Name: dashboard_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: appuser
--

SELECT pg_catalog.setval('public.dashboard_metrics_id_seq', 1, false);


--
-- Name: tourist_names_i18n_id_seq; Type: SEQUENCE SET; Schema: public; Owner: appuser
--

SELECT pg_catalog.setval('public.tourist_names_i18n_id_seq', 3, true);


--
-- Name: ai_events ai_events_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.ai_events
    ADD CONSTRAINT ai_events_pkey PRIMARY KEY (id);


--
-- Name: alert_logs alert_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.alert_logs
    ADD CONSTRAINT alert_logs_pkey PRIMARY KEY (id);


--
-- Name: dashboard_metrics dashboard_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.dashboard_metrics
    ADD CONSTRAINT dashboard_metrics_pkey PRIMARY KEY (id);


--
-- Name: digital_ids digital_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.digital_ids
    ADD CONSTRAINT digital_ids_pkey PRIMARY KEY (id);


--
-- Name: iot_devices iot_devices_device_id_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_devices
    ADD CONSTRAINT iot_devices_device_id_key UNIQUE (device_id);


--
-- Name: iot_devices iot_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_devices
    ADD CONSTRAINT iot_devices_pkey PRIMARY KEY (id);


--
-- Name: iot_events iot_events_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_events
    ADD CONSTRAINT iot_events_pkey PRIMARY KEY (id);


--
-- Name: itineraries itineraries_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT itineraries_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (code);


--
-- Name: safety_scores safety_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.safety_scores
    ADD CONSTRAINT safety_scores_pkey PRIMARY KEY (id);


--
-- Name: tourist_names_i18n tourist_names_i18n_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tourist_names_i18n
    ADD CONSTRAINT tourist_names_i18n_pkey PRIMARY KEY (id);


--
-- Name: tourist_names_i18n tourist_names_i18n_tourist_id_language_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tourist_names_i18n
    ADD CONSTRAINT tourist_names_i18n_tourist_id_language_key UNIQUE (tourist_id, language);


--
-- Name: tourists tourists_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tourists
    ADD CONSTRAINT tourists_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_events_time; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_ai_events_time ON public.ai_events USING btree (event_time DESC);


--
-- Name: idx_alert_logs_geo; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_alert_logs_geo ON public.alert_logs USING btree (latitude, longitude);


--
-- Name: idx_alert_logs_time; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_alert_logs_time ON public.alert_logs USING btree (alert_time DESC);


--
-- Name: idx_iot_events_time; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_iot_events_time ON public.iot_events USING btree (event_time DESC);


--
-- Name: uq_dashboard_metrics_key; Type: INDEX; Schema: public; Owner: appuser
--

CREATE UNIQUE INDEX uq_dashboard_metrics_key ON public.dashboard_metrics USING btree (metric_date, metric_key, COALESCE((dimensions ->> 'scope'::text), 'global'::text));


--
-- Name: uq_digital_ids_active_per_tourist; Type: INDEX; Schema: public; Owner: appuser
--

CREATE UNIQUE INDEX uq_digital_ids_active_per_tourist ON public.digital_ids USING btree (tourist_id) WHERE is_active;


--
-- Name: ai_events ai_events_related_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.ai_events
    ADD CONSTRAINT ai_events_related_alert_id_fkey FOREIGN KEY (related_alert_id) REFERENCES public.alert_logs(id) ON DELETE SET NULL;


--
-- Name: ai_events ai_events_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.ai_events
    ADD CONSTRAINT ai_events_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE SET NULL;


--
-- Name: alert_logs alert_logs_itinerary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.alert_logs
    ADD CONSTRAINT alert_logs_itinerary_id_fkey FOREIGN KEY (itinerary_id) REFERENCES public.itineraries(id) ON DELETE SET NULL;


--
-- Name: alert_logs alert_logs_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.alert_logs
    ADD CONSTRAINT alert_logs_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE SET NULL;


--
-- Name: digital_ids digital_ids_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.digital_ids
    ADD CONSTRAINT digital_ids_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE CASCADE;


--
-- Name: iot_devices iot_devices_owner_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_devices
    ADD CONSTRAINT iot_devices_owner_tourist_id_fkey FOREIGN KEY (owner_tourist_id) REFERENCES public.tourists(id) ON DELETE SET NULL;


--
-- Name: iot_events iot_events_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_events
    ADD CONSTRAINT iot_events_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.iot_devices(id) ON DELETE SET NULL;


--
-- Name: iot_events iot_events_related_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_events
    ADD CONSTRAINT iot_events_related_alert_id_fkey FOREIGN KEY (related_alert_id) REFERENCES public.alert_logs(id) ON DELETE SET NULL;


--
-- Name: iot_events iot_events_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.iot_events
    ADD CONSTRAINT iot_events_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE SET NULL;


--
-- Name: itineraries itineraries_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT itineraries_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE CASCADE;


--
-- Name: safety_scores safety_scores_related_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.safety_scores
    ADD CONSTRAINT safety_scores_related_alert_id_fkey FOREIGN KEY (related_alert_id) REFERENCES public.alert_logs(id) ON DELETE SET NULL;


--
-- Name: safety_scores safety_scores_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.safety_scores
    ADD CONSTRAINT safety_scores_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE CASCADE;


--
-- Name: tourist_names_i18n tourist_names_i18n_tourist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tourist_names_i18n
    ADD CONSTRAINT tourist_names_i18n_tourist_id_fkey FOREIGN KEY (tourist_id) REFERENCES public.tourists(id) ON DELETE CASCADE;


--
-- Name: DATABASE myapp; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE myapp TO appuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO appuser;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO appuser;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO appuser;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO appuser;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO appuser;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO appuser;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO appuser;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO appuser;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO appuser;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO appuser;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO appuser;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict auiNlK1L6BVr85KTXexfleWCQwe31NzlUGxGH3dvCUnrrXUog0IkpD4I4JS8qgo


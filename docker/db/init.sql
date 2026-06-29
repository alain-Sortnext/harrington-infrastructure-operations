-- Harrington Capital plc -- Database Init
-- Phase 4: Docker deployment

CREATE TABLE IF NOT EXISTS infrastructure_log (
    id          SERIAL PRIMARY KEY,
    timestamp   TIMESTAMPTZ DEFAULT NOW(),
    event_type  VARCHAR(50),
    host        VARCHAR(100),
    message     TEXT
);

INSERT INTO infrastructure_log (event_type, host, message) VALUES
    ('STARTUP',   'hc-db',    'Database initialised for Harrington Capital ops portal'),
    ('INFO',      'hc-app',   'Application layer connected to database'),
    ('INFO',      'hc-nginx', 'Reverse proxy routing to application');

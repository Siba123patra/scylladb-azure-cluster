-- ScyllaDB TTL (Time-To-Live) Configuration Examples

CREATE KEYSPACE IF NOT EXISTS myapp
  WITH replication = {'class': 'NetworkTopologyStrategy', 'eastus': 3}
  AND durable_writes = true;

USE myapp;

-- Table with 30-day default TTL and TWCS compaction
CREATE TABLE IF NOT EXISTS events (
  event_id UUID    PRIMARY KEY,
  user_id  UUID,
  payload  TEXT,
  created  TIMESTAMP
) WITH default_time_to_live = 2592000
   AND compaction = {
     'class': 'TimeWindowCompactionStrategy',
     'compaction_window_unit': 'DAYS',
     'compaction_window_size': 1
   }
   AND gc_grace_seconds = 86400;

-- Insert using table default TTL
INSERT INTO events (event_id, user_id, payload, created)
VALUES (uuid(), uuid(), 'page_view', toTimestamp(now()));

-- Insert with custom 1-hour TTL
INSERT INTO events (event_id, user_id, payload, created)
VALUES (uuid(), uuid(), 'temp_event', toTimestamp(now()))
USING TTL 3600;

-- Check remaining TTL
SELECT event_id, TTL(payload) FROM events LIMIT 10;

-- Alter default TTL to 7 days
ALTER TABLE events WITH default_time_to_live = 604800;

-- Force compaction to reclaim expired tombstones
-- nodetool compact myapp events

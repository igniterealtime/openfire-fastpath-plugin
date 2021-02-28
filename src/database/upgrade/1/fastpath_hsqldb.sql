ALTER TABLE fpQueue ADD COLUMN dispatcherClass VARCHAR(4000) NULL;
ALTER TABLE fpOfflineSetting ADD COLUMN redirectMUC VARCHAR(255) NULL;

ALTER TABLE fpWorkgroup ALTER COLUMN schedule CLOB;
ALTER TABLE fpWorkgroupProp ALTER COLUMN propValue CLOB;
ALTER TABLE fpAgentProp ALTER COLUMN propValue CLOB;
ALTER TABLE fpDispatcherProp ALTER COLUMN propValue CLOB;
ALTER TABLE fpQueueProp ALTER COLUMN propValue CLOB;
ALTER TABLE fpSessionProp ALTER COLUMN propValue CLOB;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

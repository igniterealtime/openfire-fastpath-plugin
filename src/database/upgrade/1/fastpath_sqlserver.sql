ALTER TABLE fpQueue ADD dispatcherClass NVARCHAR(3900) NULL;
ALTER TABLE fpOfflineSetting ADD redirectMUC NVARCHAR(255) NULL;

ALTER TABLE fpWorkgroup ALTER COLUMN schedule TEXT NULL;
ALTER TABLE fpWorkgroupProp ALTER COLUMN propValue TEXT NOT NULL;
ALTER TABLE fpAgentProp ALTER COLUMN propValue TEXT NOT NULL;
ALTER TABLE fpDispatcherProp ALTER COLUMN propValue TEXT NOT NULL;
ALTER TABLE fpQueueProp ALTER COLUMN propValue TEXT NOT NULL;
ALTER TABLE fpSessionProp ALTER COLUMN propValue TEXT NOT NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

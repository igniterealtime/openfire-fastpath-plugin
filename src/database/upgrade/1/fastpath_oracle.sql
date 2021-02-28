ALTER TABLE fpQueue ADD dispatcherClass VARCHAR(3900) NULL;
ALTER TABLE fpOfflineSetting ADD redirectMUC VARCHAR2(255) NULL;

ALTER TABLE fpWorkgroup ADD (schedule_new NCLOB NULL);
UPDATE fpWorkgroup SET schedule_new = schedule;
ALTER TABLE fpWorkgroup DROP COLUMN schedule;
ALTER TABLE fpWorkgroup RENAME schedule_new TO schedule;

ALTER TABLE fpWorkgroupProp ADD (propValue_new NCLOB NOT NULL);
UPDATE fpWorkgroupProp SET propValue_new = propValue;
ALTER TABLE fpWorkgroupProp DROP COLUMN propValue;
ALTER TABLE fpWorkgroupProp RENAME propValue_new TO propValue;

ALTER TABLE fpAgentProp ADD (propValue_new NCLOB NOT NULL);
UPDATE fpAgentProp SET propValue_new = propValue;
ALTER TABLE fpAgentProp DROP COLUMN propValue;
ALTER TABLE fpAgentProp RENAME propValue_new TO propValue;

ALTER TABLE fpDispatcherProp ADD (propValue_new NCLOB NOT NULL);
UPDATE fpDispatcherProp SET propValue_new = propValue;
ALTER TABLE fpDispatcherProp DROP COLUMN propValue;
ALTER TABLE fpDispatcherProp RENAME propValue_new TO propValue;

ALTER TABLE fpQueueProp ADD (propValue_new NCLOB NOT NULL);
UPDATE fpQueueProp SET propValue_new = propValue;
ALTER TABLE fpQueueProp DROP COLUMN propValue;
ALTER TABLE fpQueueProp RENAME propValue_new TO propValue;

ALTER TABLE fpSessionProp ADD (propValue_new NCLOB NOT NULL);
UPDATE fpSessionProp SET propValue_new = propValue;
ALTER TABLE fpSessionProp DROP COLUMN propValue;
ALTER TABLE fpSessionProp RENAME propValue_new TO propValue;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

commit;

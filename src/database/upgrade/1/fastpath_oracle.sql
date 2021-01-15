ALTER TABLE fpQueue ADD dispatcherClass VARCHAR(3900) NULL;
ALTER TABLE fpOfflineSetting ADD redirectMUC VARCHAR2(255) NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

commit;

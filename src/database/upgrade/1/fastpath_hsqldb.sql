ALTER TABLE fpQueue ADD COLUMN dispatcherClass VARCHAR(4000) NULL;
ALTER TABLE fpOfflineSetting ADD COLUMN redirectMUC VARCHAR(255) NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

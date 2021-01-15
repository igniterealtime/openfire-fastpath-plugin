ALTER TABLE fpQueue ADD dispatcherClass NVARCHAR(3900) NULL;
ALTER TABLE fpOfflineSetting ADD redirectMUC NVARCHAR(255) NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

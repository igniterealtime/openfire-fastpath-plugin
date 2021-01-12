ALTER TABLE fpQueue ADD COLUMN dispatcherClass TEXT NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

ALTER TABLE fpQueue ADD COLUMN dispatcherClass LONG VARCHAR NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

ALTER TABLE fpQueue ADD dispatcherClass VARCHAR(3900) NULL;

-- Update database version
UPDATE ofVersion SET version = 1 WHERE name = 'fastpath';

commit;

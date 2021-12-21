\set lectoruser `echo $USER`
\set lectordatabase 'lector_chile'

\c :lectordatabase

ALTER TABLE noticias ALTER COLUMN titular TYPE VARCHAR(500);



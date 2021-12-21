\set lectoruser `echo $USER`
\set lectordatabase 'lector_chile'

\c :lectordatabase

create table updated_at (
    dt timestamptz NOT NULL PRIMARY KEY
);
alter table updated_at OWNER TO :lectoruser;
grant insert, update, delete, select on table updated_at to :lectoruser;

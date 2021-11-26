\set lectoruser `echo $LECTOR_PSQL_USER`
\set lectorpass `echo $LECTOR_PSQL_PASS`
\set lectordatabase `echo $LECTOR_PSQL_DATABASE`

CREATE DATABASE :lectordatabase;
CREATE USER :lectoruser WITH ENCRYPTED PASSWORD :'lectorpass';
GRANT CONNECT ON DATABASE :lectordatabase TO :lectoruser;

\c :lectordatabase

create table medios (
    medio_id bigserial PRIMARY KEY,
    nombre varchar(50) NOT NULL
);
grant insert, update, delete, select on table medios to :lectoruser;

create table secciones (
    seccion_id bigserial PRIMARY KEY,
    seccion varchar(50) NOT NULL
);
grant insert, update, delete, select on table secciones to :lectoruser;

create table noticias (
    medio_id bigint REFERENCES medios (medio_id),
    seccion_id bigint REFERENCES secciones (seccion_id),
    autor varchar(50),
    fecha timestamptz,
    titular varchar(200) NOT NULL,
    bajada text,
    imagen_url text,
    cuerpo text NOT NULL,
    url text,

    PRIMARY KEY (url),
    UNIQUE (titular, medio_id)
);
grant insert, update, delete, select on table noticias to :lectoruser;


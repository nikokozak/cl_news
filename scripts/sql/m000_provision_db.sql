\set lectoruser `echo $USER`
\set lectordatabase 'lector_chile'

CREATE DATABASE :lectordatabase;
CREATE USER :lectoruser;
-- TODO: See if we can get rid of the grants for each table like this.
-- Either way I need ownership so I can perform ident-authed migrations.
ALTER DATABASE :lectordatabase OWNER TO :lectoruser;
GRANT CONNECT ON DATABASE :lectordatabase TO :lectoruser;

\c :lectordatabase

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- for generating noticia UUID's

-- CREATE TABLES

create table medios (
    medio_id bigserial PRIMARY KEY,
    nombre varchar(50) NOT NULL,
    std varchar(50) NOT NULL
);
alter table medios OWNER TO :lectoruser;
grant insert, update, delete, select on table medios to :lectoruser;

create table secciones (
    seccion_id bigserial PRIMARY KEY,
    nombre varchar(50) NOT NULL,
    std varchar(50) NOT NULL
);
alter table medios OWNER TO :lectoruser;
grant insert, update, delete, select on table secciones to :lectoruser;

create table noticias (
    noticia_id UUID NOT NULL DEFAULT uuid_generate_v1mc(),
    medio_id bigint NOT NULL REFERENCES medios (medio_id),
    seccion_id bigint NOT NULL REFERENCES secciones (seccion_id),
    autor varchar(50),
    fecha timestamptz,
    titular varchar(200) NOT NULL,
    bajada text,
    imagen_url text,
    cuerpo text[] NOT NULL, -- Text is an array of "paragraphs" to aid in formatting.
    url text,

    PRIMARY KEY (noticia_id),
    UNIQUE (url),
    UNIQUE (titular, medio_id)
);
alter table medios OWNER TO :lectoruser;
grant insert, update, delete, select on table noticias to :lectoruser;

grant usage, select on all sequences in schema public to :lectoruser;

-- POPULATE VALUES

insert into medios (nombre, std)
values
    ('Radio Bío Bío', 'biobio'),
    ('El Mercurio Online', 'emol'),
    ('La Tercera', 'tercera'),
    ('CIPER Chile', 'ciper'),
    ('El Mostrador', 'mostrador');

insert into secciones (nombre, std)
values
    ('Nacional', 'nacional'),
    ('Política', 'politica'),
    ('Internacional', 'internacional'),
    ('Economía', 'economia'),
    ('Tecnología', 'tecnologia'),
    ('Educación', 'educacion'),
    ('Opinión', 'opinion'),
    ('Tendencias', 'tendencias');

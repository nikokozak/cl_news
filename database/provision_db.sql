
\set lectoruser `echo $LECTOR_PSQL_USER`
\set lectorpass `echo $LECTOR_PSQL_PASS`
\set lectordatabase `echo $LECTOR_PSQL_DATABASE`

CREATE DATABASE :lectordatabase;
CREATE USER :lectoruser WITH ENCRYPTED PASSWORD :'lectorpass';
GRANT CONNECT on DATABASE :lectordatabase to :lectoruser;



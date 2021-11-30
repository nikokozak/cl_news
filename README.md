## Scraping:

The scraper can be found in the `scraper` folder. It consists of a somewhat heavily modified Scrapy implementation,
and can be called from the command line by running `poetry run python3 scraper.py`. 

Scraping rules can be found under `scraper/scraper/spiders/site_rules.py`.

By default, every spider saves its new results in a cache file, who's folder can be determined by setting 
an option in `scraper/scraper/settings.py`.

At present, I'm doing a naughty thing and setting id conversions in the Pipeline. This will soon be replaced with an appropriate
SQL expression.

Connection with the running psql instance is handled in `scraper/scraper/pipelines.py`, and is set to autocommit after ever command.

## Database:

The database is psql populated by a few tables, namely `noticias`, `medios`, `secciones`. In order to use set up the database:
- The name of the database, along with the user info and password for the user are set as environment variables with the `./populate_env.sh` script (see source for specifics on how to run it in different shells).
- Once set, ensure that both database and user don't exist by running `dropdb $LECTOR_PSQL_DATABASE` and `dropuser $LECTOR_PSQL_USER`.
- Run the `database/provision_db.sh` script. Ensure that the "uuid-ossp" extension is available.
- At the moment, the `medios` and `secciones` tables are populated via the `database/dummy_data.sql` script, which can be run via the `psql -f dummy_data.sql` shell command. This will eventually be moved up to the provision_db script.
- You should be able to populate and read from the database now!

## Server:

The server is a hand-rolled Plug-Cowboy based elixir app, using Postgrex to connect with the database (maybe I should use Ecto).
- The port settings are set in the `server/lib/lector.ex` entrypoint. 
- To run the server, execute the `mix run --no-halt` command.

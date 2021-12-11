import Config

# These options are set at RUNTIME! 
# In theory this means we can read our $USER, and use this value as peer ident for 
# our database both in dev & prod

config :lector, :db,
  username: System.get_env("USER", "lector"),
  database: System.get_env("LECTOR_DB_NAME", "lector_chile")

config :lector, :network,
  port: System.get_env("LECTOR_PORT", "8080")


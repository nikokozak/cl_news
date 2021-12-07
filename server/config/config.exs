import Config

config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}],
  format: "[$level] $message\n",
  level: :info

config :logger, :error_log,
  path: "logs/info.log",
  level: :info

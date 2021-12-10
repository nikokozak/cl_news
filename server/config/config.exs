import Config

config :lector,
  template_dir: "lib/templates",
  layout_dir: "lib/templates/layouts",
  default_layout: "base.html.eex"

config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}],
  format: "[$level] $message\n",
  level: :info

config :logger, :error_log,
  path: "logs/info.log",
  level: :info

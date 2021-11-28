defmodule Lector.Endpoint do
  use Plug.Builder

  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ['*/*']

  plug Lector.Router
end

defmodule Lector.Endpoint do
  use Plug.Builder

  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ['*/*']

  plug Plug.Static,
    at: "/",
    from: {:lector, "lib/assets"}

  plug Lector.Router
end

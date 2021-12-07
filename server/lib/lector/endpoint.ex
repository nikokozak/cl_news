defmodule Lector.Endpoint do
  use Plug.Builder

  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ['*/*']

  plug Plug.Static,
    at: "/assets", 
    from: :lector

  plug Lector.Router
end

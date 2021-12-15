defmodule Lector.Endpoint do
  use Plug.Builder

  plug :time_init_plug

  plug Plug.Parsers,
    parsers: [:urlencoded],
    pass: ['*/*']

  plug Plug.Static,
    at: "/assets", 
    from: :lector

  plug Lector.Router

  def time_init_plug(conn, _opts) do
    Plug.Conn.assign(conn, :timing_init, System.monotonic_time(:millisecond))
  end
end

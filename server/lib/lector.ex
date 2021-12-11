defmodule Lector do
  use Application
  require Logger
  @moduledoc """
  Base module called on by `mix run` for app orchestration.
  """

  @doc """
  Called by `mix run` on start. 
  Starts a supervision tree, runs Plug to handle incoming conns.
  """
  def start(_type, _args) do

    application_port = get_port()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Lector.Endpoint, options: [port: application_port]},
      {Lector.DB, []},
      {Lector.Cache, []}
    ]

    opts = [
      strategy: :one_for_one,
      name: Lector.Supervisor
    ]
    
    Logger.info("Starting server at port #{application_port}")
    Supervisor.start_link(children, opts)
  end

  defp get_port do
    { port, _ } =
      Application.get_env(:lector, :network) 
      |> Keyword.get(:port) 
      |> Integer.parse

    port
  end

end

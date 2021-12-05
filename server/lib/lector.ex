defmodule Lector do
  use Application
  @moduledoc """
  Base module called on by `mix run` for app orchestration.
  """

  @doc """
  Called by `mix run` on start. 
  Starts a supervision tree, runs Plug to handle incoming conns.
  """
  def start(_type, _args) do

    children = [
      {Plug.Cowboy, scheme: :http, plug: Lector.Endpoint, options: [port: 8080]},
      {Lector.DB, []},
      {Lector.Cache, []}
    ]

    opts = [
      strategy: :one_for_one,
      name: Lector.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

end

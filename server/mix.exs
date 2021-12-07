defmodule Lector.MixProject do
  use Mix.Project

  def project do
    [
      app: :lector,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Lector, []}, # Called by "mix run" on start
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.15"},
      {:poolboy, "~> 1.5.0"},
      {:logger_file_backend, "~> 0.0.10"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

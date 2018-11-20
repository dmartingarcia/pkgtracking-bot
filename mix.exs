defmodule App.Mixfile do
  use Mix.Project

  def project do
    [app: :app,
     version: "0.1.0",
     elixir: "~> 1.3",
     # default_task: "server",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: [
        vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
     ],
     deps: deps(),
     aliases: aliases()]
  end

  def application do
    [applications: applications(Mix.env),
     mod: {App, []}]
  end

  defp applications(:dev), do: applications(:all) ++ [:remix]
  defp applications(_all), do: [:postgrex, :logger, :nadia, :ecto_sql, :httpoison]

  defp deps do
    [{:nadia, "~> 0.4.1"},
     {:ecto_sql, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:exvcr, "~> 0.10", only: :test},
     {:httpoison, "~> 1.1"},
     {:meeseeks, "~> 0.10.1"},
     {:remix, "~> 0.0.1", only: :dev}]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end

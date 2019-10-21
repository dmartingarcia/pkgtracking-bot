use Mix.Config

config :app,
  bot_name:  System.get_env("TELEGRAM_NAME") || "",
  ecto_repos: [App.Repo]

config :nadia,
  token: System.get_env("TELEGRAM_TOKEN") || ""

config :app, App.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USERNAME"),
  password: System.get_env("PG_USERNAME"),
  database: "pkgtracker_dev",
  hostname: System.get_env("PG_HOST"),
  pool_size: 10

config :remix,
  escript: true,
  silent: false

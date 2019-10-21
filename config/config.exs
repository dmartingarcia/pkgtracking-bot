use Mix.Config

config :app,
  bot_name: System.get_env("TELEGRAM_NAME") || "pkgtracker",
  ecto_repos: [App.Repo]

config :nadia,
  token: System.get_env("TELEGRAM_TOKEN") || ""

config :app, App.Repo,
  database: "pkgtracker_#{Mix.env}",
  username: System.get_env("PG_USERNAME") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  hostname: System.get_env("PG_HOST") || "localhost",
  port: "5432"

import_config "#{Mix.env}.exs"

use Mix.Config

config :app,
  bot_name: "",
  ecto_repos: [App.Repo]

config :nadia,
  token: ""

config :app, App.Repo,
  database: "trackingbot_#{Mix.env}",
  username: System.get_env("PG_USERNAME") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  hostname: System.get_env("PG_HOST") || "localhost",
  port: "5432"


import_config "#{Mix.env}.exs"

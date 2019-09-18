# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :phoenix, :json_libary, Jason

# General application configuration
config :job_board,
  ecto_repos: [JobBoard.Repo]

# Configures the endpoint
config :job_board, JobBoardWeb.Endpoint,
  http: [
    compress: true,
    protocol_options: [max_keepalive: 10_000]
  ],
  url: [host: "localhost"],
  secret_key_base: "X3Pa078XvNgQJi+SAz66Zb/ryWt2m8y1UF9TsKR6IH/c8bCD9tx3CohW6imxc1ix",
  render_errors: [view: JobBoardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JobBoard.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :job_board, JobBoard.Repo,
  types: JobBoard.PostgrexTypes

config :stripy,
  endpoint: "https://api.stripe.com/v1/", # optional
  version: "2018-10-31", # optional
  httpoison: [recv_timeout: 5000, timeout: 8000] # optional

config :number, currency: [
  unit: "$",
  precision: 2,
  delimiter: ",",
  seperator: ".",
  format: "%u%n",
  negative_format: "-%u%n"
]

config :mailchimp,
  api_key: System.get_env("MAILCHIMP_API_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"



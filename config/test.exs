use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :job_board, JobBoardWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :job_board, JobBoard.Repo,
  username: "postgres",
  password: "postgres",
  database: "job_board_test",
  hostname: "localhost",  
  url: System.get_env("DATABASE_URL_TEST"),
  pool: Ecto.Adapters.SQL.Sandbox


config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :job_board, JobBoard.Mailer,
  adapter: Bamboo.TestAdapter

config :stripy,
  testing: true,
  mock_server: JobBoard.StripeMockServer

# config :job_board, :recaptcha, JobBoard.RecaptchaMockServer

config :recaptcha,
  http_client: Recaptcha.Http.MockClient,
  public_key: "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI",
  secret: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

config :mailchimp,
  mock_server: Mailchimp.MockServer

config :stripy,
  public_key: "test"

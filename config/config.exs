# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :jyz_backend,
  ecto_repos: [JyzBackend.Repo]

# Configures the endpoint
config :jyz_backend, JyzBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HscAoPkeF6E7p9DFXwHkXauJmv9TAGsXS/YAmEXH+iCJe+bKchzGygQwFgW8Xdda",
  render_errors: [view: JyzBackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JyzBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Guardian
config :jyz_backend, JyzBackend.Guardian,
issuer: "jyz_backend",
secret_key: "o5FtWVptxLYXJ8LIgSX0Bxkqfa0nwihIPHcfXeHDLAXlGQAjTF9Kh40Wp7rVUtp+"

# Store uploaded file in local storage
config :arc,
storage: Arc.Storage.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

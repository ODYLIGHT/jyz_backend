defmodule JyzBackendWeb.Router do
  use JyzBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Corsica, origins: "*"
  end

  pipeline :api_auth do  
    plug Guardian.Plug.Pipeline, module: JyzBackend.Guardian,
      error_handler: JyzBackend.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/api/v1", JyzBackendWeb do
    pipe_through :api

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    post "/users", UserController, :new
    get "/users/username/:username", UserController, :checkUsername
    post "/login", LoginController, :login
  end

end

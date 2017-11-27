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

  scope "/api/v1", JyzBackendWeb do
    pipe_through [:api, :api_auth]

    post "/users/avatar/:id", UserController, :setAvatar
    delete "/users/:id", UserController, :delete
    post "/users/:id", UserController, :update
    post "/users/:id/activate", UserController, :activateUser
    post "/users/changepwd", UserController, :changePassword
    

    # 采购合同
    get "/contract_for_purchase", ContractForPurchaseController, :index
    get "/contract_for_purchase/:id", ContractForPurchaseController, :show
    post "/contract_for_purchase", ContractForPurchaseController, :new
    delete "/contract_for_purchase/:id", ContractForPurchaseController, :delete
    post "/contract_for_purchase/:id", ContractForPurchaseController, :update
    get "/contract_for_purchase/audit/:id", ContractForPurchaseController, :audit

    
    # 油品回罐
    get "/metering_for_return", MeteringForReturnController, :index
    get "/metering_for_return/:id", MeteringForReturnController, :show
    post "/metering_for_return", MeteringForReturnController, :new
    delete "/metering_for_return/:id", MeteringForReturnController, :delete
    post "/metering_for_return/:id", MeteringForReturnController, :update
    get "/metering_for_return/audit/:id", MeteringForReturnController, :audit
  end

end

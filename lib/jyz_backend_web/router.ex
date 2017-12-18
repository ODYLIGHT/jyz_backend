defmodule JyzBackendWeb.Router do
  use JyzBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    # plug Corsica, allow_headers: ["accept"], origins: "*"
  end

  pipeline :api_auth do  
    plug Guardian.Plug.Pipeline, module: JyzBackend.Guardian,
      error_handler: JyzBackend.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/api/v1", JyzBackendWeb do
    pipe_through :api
 
   
    get "/users/username/:username", UserController, :checkUsername
    post "/login", LoginController, :login

    

    

    
  end

  scope "/api/v1", JyzBackendWeb do
    pipe_through [:api, :api_auth]
    post "/users/:id/activate", UserController, :activateUser
    post "/users/avatar/:id", UserController, :setAvatar
    delete "/users/:id", UserController, :delete
    post "/users/:id", UserController, :update

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    post "/users", UserController, :new
   
    post "/users/changepwd", UserController, :changePassword

    # 查看库存变化量
    get "/stock_change", StockChangeController, :index

    # 采购合同
    get "/contract_for_purchase", ContractForPurchaseController, :index
    get "/contract_for_purchase/:id", ContractForPurchaseController, :show
    post "/contract_for_purchase", ContractForPurchaseController, :new
    delete "/contract_for_purchase/:id", ContractForPurchaseController, :delete
    post "/contract_for_purchase/:id", ContractForPurchaseController, :update
    get "/contract_for_purchase/audit/:id", ContractForPurchaseController, :audit

    #油品移库
    get "/oil_transfer", OilTransferController, :index
    get "/oil_transfer/:id", OilTransferController, :show
    post "/oil_transfer", OilTransferController, :new
    delete "/oil_transfer/:id", OilTransferController, :delete
    post "/oil_transfer/:id", OilTransferController, :update
    get "/oil_transfer/audit/:id", OilTransferController, :audit

    #油品配送出库单
    get "/dispatch_for_purchase", DispatchForPurchaseController, :index
    get "/dispatch_for_purchase/:id", DispatchForPurchaseController, :show
    post "/dispatch_for_purchase", DispatchForPurchaseController, :new
    delete "/dispatch_for_purchase/:id", DispatchForPurchaseController, :delete
    post "/dispatch_for_purchase/:id", DispatchForPurchaseController, :update
    get "/dispatch_for_purchase/audit/:id", DispatchForPurchaseController, :audit


    
    # 油品回罐
    get "/metering_for_return", MeteringForReturnController, :index
    get "/metering_for_return/:id", MeteringForReturnController, :show
    post "/metering_for_return", MeteringForReturnController, :new
    delete "/metering_for_return/:id", MeteringForReturnController, :delete
    post "/metering_for_return/:id", MeteringForReturnController, :update
    get "/metering_for_return/audit/:id", MeteringForReturnController, :audit

    #仓库信息
    get "/oil_depot", OilDepotController, :index
    get "/oil_depot/:id", OilDepotController, :show
    post "/oil_depot", OilDepotController, :new
    delete "/oil_depot/:id", OilDepotController, :delete
    post "/oil_depot/:id", OilDepotController, :update

    #油品入库校验单
    get "/godownentry_for_acceptance", GodownentryForAcceptanceController, :index
    get "/godownentry_for_acceptance/:id", GodownentryForAcceptanceController, :show
    post "/godownentry_for_acceptance", GodownentryForAcceptanceController, :new
    delete "/godownentry_for_acceptance/:id", GodownentryForAcceptanceController, :delete
    post "/godownentry_for_acceptance/:id", GodownentryForAcceptanceController, :update
    get "/godownentry_for_acceptance/audit/:id", GodownentryForAcceptanceController, :audit
   
   #油品销售提用表
    get "/carry_for_account", CarryForAccountController, :index
    get "/carry_for_account/:id", CarryForAccountController, :show
    post "/carry_for_account", CarryForAccountController, :new
    delete "/carry_for_account/:id", CarryForAccountController, :delete
    post "/carry_for_account/:id", CarryForAccountController, :update
    get "/carry_for_account/audit/:id", CarryForAccountController, :audit
 

  #数据字典
    get "/dict", DictController, :index
    get "/dict/:id", DictController, :show
    post "/dict", DictController, :new
    delete "/dict/:id", DictController, :delete
    post "/dict/:id", DictController, :update
 end

  # scope "/api/v1", JyzBackendWeb do
  #   pipe_through :api

  #   get "oil_depot",OilDepotController, :index
  #   get "oil_depot/:id",OilDepotController, :show
  #   post "oil_depot",OilDepotController, :new
  #   delete "oil_depot/:id",OilDepotController, :delete
  #   post "oil_depot/:id",OilDepotController, :update
    
  # end

end

defmodule JyzBackendWeb.StockChangeController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{StockChange, StockChangeService, Permissions, Guardian, Periodically, DictService}
  
    def index(conn, params) do
      # d = GenServer.call(AppDict, :get_dict)
      cno = Map.get(params, "cno", "")
      sort_field = Map.get(params, "sort_field", "inserted_at")
      sort_direction = Map.get(params, "sort_direction", "desc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
      json conn, StockChangeService.page(cno,sort_field,sort_direction,page,page_size)
    end  
end
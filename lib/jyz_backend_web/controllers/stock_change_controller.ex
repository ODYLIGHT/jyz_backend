defmodule JyzBackendWeb.StockChangeController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{StockChange, StockChangeService, Permissions, Guardian, Periodically, OilDepotService}
  
    def index(conn, params) do
      # d = GenServer.call(AppDict, :get_dict)
      r = OilDepotService.calculateStock()
      # scs = StockChangeService.find_stock_change_from_oildepot("11")
      IO.puts("##############")
      IO.puts inspect r

      cno = Map.get(params, "cno", "")
      warehouse = Map.get(params, "warehouse", "")
      type = Map.get(params, "type", "")
      sort_field = Map.get(params, "sort_field", "inserted_at")
      sort_direction = Map.get(params, "sort_direction", "desc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
      json conn, StockChangeService.page(cno,warehouse,type,sort_field,sort_direction,page,page_size)
    end  
end
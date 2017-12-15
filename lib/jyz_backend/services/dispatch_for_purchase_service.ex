defmodule JyzBackend.DispatchForPurchaseService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{DispatchForPurchase, DispatchForPurchaseDetail,UserService, OilDepotService,StockChange, StockChangeService, Repo}
    alias Ecto.Multi
    def page(billno \\ "", audited \\ "null", sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{billno}%"
    
      query = from u in DispatchForPurchase,
                  where: like(u.billno , ^like_term),
                  order_by: ^sort_by,
                  preload: [:dispatch_for_purchase_details]
      # 动态增加查询条件
      case audited do
        "true" -> query = from u in query,
                      where:  u.audited == true
        "false" -> query = from u in query,
                      where:  u.audited == false
        _ -> query = query
      end
    
      page = query |> Repo.paginate(page: page, page_size: page_size)
        
      cond do
        page.entries > 0 ->
          %{page | entries: page.entries 
                  |> Enum.map(fn(c) -> Map.drop(c, [:dispatch_for_purchase_details]) end)}
                  # |> Enum.map(fn(c) -> Map.update("creater", "", &(UserService.getUsername(&1))) end)}
        true ->
          page
      end
  
    end
    
    def getById(id) do
      c = Repo.one from c in DispatchForPurchase,
           where: c.id == ^id,
           preload: [:dispatch_for_purchase_details] 
       case c do
        nil -> c
        c -> c |> Map.update("creater", "", &(UserService.getUsername(&1)))
      end  
    end
  
    def create(changeset) do
      Repo.insert(changeset)
    end

    def delete(c) do
      Repo.delete(c) 
    end

    def update(changeset) do
      Repo.update(changeset)
    end
  
  
  # 设置审核入库的整个过程在一个事务中,接受两个参数，入库校验单和入库校验单审核changeset
    def auditStockIn(dispatch, changeset) do 
      Repo.transaction(create_stock_change_from_dispatch(dispatch, changeset))
    end

   

 # 设置审核入库的整个过程在一个事务中,接受两个参数，入库校验单和入库校验单审核changeset
    def auditStockIn(dispatch, changeset) do 
      Repo.transaction(create_stock_change_from_dispatch(dispatch, changeset))
    end

    # 审核将通过所有明细，生成库存变化记录StockChange
    defp create_stock_change_from_dispatch(dispatch_with_details, changeset) do
      # 生成multi
      multi = Multi.new
      # 获得明细用以生成StockChange
      details = dispatch_with_details.dispatch_for_purchase_details
      # 获取单号用以填充StockChange的cno字段
      cno = dispatch_with_details.billno
      sp = dispatch_with_details.stockplace

      # 获取StockChange类型，这里是油品入库校验
      m = GenServer.call(AppDict, :get_dict)
      itype = Map.get(m,"stockchange_type_dispatch")
      #itype = "stockchange_type_dispatch"
      
      # 由明细生成StockChange map的list
      case details do
        nil -> multi
        details ->
          details 
            
            |> Enum.map(fn(d) -> %{cno: cno, date: "", model: d.oilname, amount: d.quantity, warehouse: sp, type: itype, stockin: true, calculated: false} end)
            # 将所有stockchange插入数据库
            |> Enum.map(fn(m) -> sc =  StockChange.changeset(%StockChange{}, m) end)
            |> Enum.with_index
            |> Enum.reduce(multi, fn({ x, i }, acc) -> acc |> Multi.insert(Integer.to_string(i), x) end)
            |> Multi.update("audit", changeset)
      end
    end 
  end
  
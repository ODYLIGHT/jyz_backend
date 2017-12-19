defmodule JyzBackend.OilTransferService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{OilTransfer, OilTransferDetail,StockChange,StockChangeService,OilDepotService, Repo}
    alias Ecto.Multi
  
    def page(billno \\ "", audited \\ "null", sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{billno}%"

      query = from u in OilTransfer,
                  where: like(u.billno , ^like_term),
                  order_by: ^sort_by,
                  preload: [:oil_transfer_details]

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
          %{page | entries: page.entries |> Enum.map(fn(u) -> Map.drop(u, [:oil_transfer_details]) end)}
        true ->
          page
      end
  
    end
    
    def getById(id) do
      Repo.one from c in OilTransfer,
        where: c.id == ^id,
        preload: [:oil_transfer_details] 
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
  
  
     # 设置审核入库的整个过程在一个事务中,接受两个参数，移库校验单和移库校验单审核changeset
     def auditStockIn(transfer, changeset) do 
      Repo.transaction(create_stock_change_from_transfer(transfer, changeset))
    end

    # 审核将通过所有明细，生成库存变化记录StockChange
    defp create_stock_change_from_transfer(transfer_with_details, changeset) do
      # 生成multi
      multi = Multi.new

      # 获得明细用以生成StockChange
      details = transfer_with_details.oil_transfer_details
      
      # 获取单号用以填充StockChange的cno字段
      cno = transfer_with_details.billno

      #获取车（罐）号用以联系仓库表找到oilname填充StockChange的model
      sp = transfer_with_details.stockplace
      od = OilDepotService.getByName(sp) 
      on = od.oilname
      
      # 获取StockChange类型，这里是油品移库校验
      # m = GenServer.call(Globalvs, :get_dict)
      # itype = m.stockchange_type_transfer

      # 由明细生成StockChange map的list
      case details do
        nil ->%{}

        details ->
          change_sets = details          
            |> Enum.map(fn(d) ->                                 
           %{cno: d.billno1, date: "", model: on, amount: d.quantity, warehouse: d.stockpalce, type: "油品移入调拨单", stockin: true, calculated: false} end)
           # 将所有stockchange插入数据库
           |> Enum.map(fn(m) -> sc =  StockChange.changeset(%StockChange{}, m) end)
           |> Enum.with_index

           multi1 = change_sets |> Enum.reduce(multi, fn({ x, i }, acc) -> acc |> Multi.insert(Integer.to_string(i), x) end)

          #由主表生成StockChange map的list
          change_main = details
            |> Enum.map(fn(b) ->             
            %{cno: cno, date: "", model: on, amount: 0-b.quantity, warehouse: sp, type: "油品移出调拨单", stockin: true, calculated: false} end)
           
            |> Enum.map(fn(m) -> sc =  StockChange.changeset(%StockChange{}, m) end)
            |> Enum.with_index
            |> Enum.reduce(multi1, fn({ x, i }, acc) -> acc |> Multi.insert("#{Integer.to_string(i)} out", x) end)
          change_main |> Multi.update("audit", changeset)
      end

    end 

  end
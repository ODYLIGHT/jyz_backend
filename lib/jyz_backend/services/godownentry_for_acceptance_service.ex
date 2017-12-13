defmodule JyzBackend.GodownentryForAcceptanceService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    alias JyzBackend.{GodownentryForAcceptance, GodownentryForAcceptanceDetail, OilDepotService, StockChange, StockChangeService, Repo}
    alias Ecto.Multi
  
    def page( bno \\ "", sort_field \\ "cno", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{bno}%"
      query = from u in GodownentryForAcceptance,
                  where: like(u.bno , ^like_term),       
                  order_by: ^sort_by,
                  preload: [:godownentry_for_acceptance_details]
      page = query |> Repo.paginate(page: page, page_size: page_size)      
      cond do
        page.entries > 0 ->
          %{page | entries: page.entries |> Enum.map(fn(u) -> Map.drop(u, [:godownentry_for_acceptance_details]) end)}
        true ->
          page
      end
  
    end
    
    def getById(id) do
      Repo.one from c in GodownentryForAcceptance,
        where: c.id == ^id,
        preload: [:godownentry_for_acceptance_details] 
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
    def auditStockIn(godown, changeset) do 
      Repo.transaction(create_stock_change_from_godown(godown, changeset))
    end

    # 审核将通过所有明细，生成库存变化记录StockChange
    defp create_stock_change_from_godown(godown_with_details, changeset) do
      # 生成multi
      multi = Multi.new
      # 获得明细用以生成StockChange
      details = godown_with_details.godownentry_for_acceptance_details
      # 获取单号用以填充StockChange的cno字段
      cno = godown_with_details.bno

      # 获取StockChange类型，这里是油品入库校验
      m = GenServer.call(Globalvs, :get_dict)
      itype = m.stockchange_type_godownentry
      
      # 由明细生成StockChange map的list
      case details do
        nil -> multi
        details ->
          details 
            
            |> Enum.map(fn(d) -> %{cno: cno, date: "", model: d.oilname, amount: d.realquantity, warehouse: d.stockplace, type: itype, stockin: true, calculated: false} end)
            # 将所有stockchange插入数据库
            |> Enum.map(fn(m) -> sc =  StockChange.changeset(%StockChange{}, m) end)
            |> Enum.with_index
            |> Enum.reduce(multi, fn({ x, i }, acc) -> acc |> Multi.insert(Integer.to_string(i), x) end)
            |> Multi.update("audit", changeset)
      end
    end 
  end
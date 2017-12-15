defmodule JyzBackend.OilDepotService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{OilDepot, StockChange, StockChangeService, DateTimeHandler, Repo}
    alias Ecto.Multi
  
    def page( depotname \\ "", sort_field \\ "depotiddr", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{depotname}%"
    
      query = from u in OilDepot,
                  where: like(u.depotname , ^like_term),
                  order_by: ^sort_by
                 # preload: [:oil_transfer_details]
    
      page = query |> Repo.paginate(page: page, page_size: page_size)
        
      # cond do
      #   page.entries > 0 ->
      #     %{page | entries: page.entries}
      #   true ->
      #     page
      # end
  
    end
    
    def getById(id) do
      Repo.one from c in OilDepot,
        where: c.id == ^id
       # preload: [:oil_transfer_details] 
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
  
    def getByName(name) do
      Repo.one from c in OilDepot,
      where: c.depotname == ^name
    end

    # 计算仓库库存
    def calculateStock() do
      # 获取所有仓库
      Repo.all(OilDepot)
        |> Enum.map(fn(d) -> calculateOneStock(d) end)
      StockChangeService.markInvalid()
    end

    # 计算一个仓库的库存，包括更新StockChange和OilDepot，且一个仓库放在一个事务中
    def calculateOneStock(oildepot) do
      case StockChangeService.find_stock_change_from_oildepot(oildepot.depotname) do
        [] -> %{}
        sc_list ->
          multi = Multi.new
          
          IO.puts inspect sc_list
          # 加入可以计算的StockChange的”修改操作“
          valid_sc_list = sc_list 
                            |> Enum.reduce([], fn(sc, acc) -> 
                                                  IO.puts inspect sc
                                                  
                                                  IO.puts inspect oildepot
                                                  
                                                  case (sc.model == oildepot.kind) do
                                                    true -> [sc | acc]
                                                    false -> acc
                                                  end
          
                                                end) 
          IO.puts("### the valid sc list is: ###")
          IO.puts inspect valid_sc_list

          multi_withvalid = valid_sc_list 
            |> Enum.map(fn(sc) ->  StockChange.changeset(sc, %{ date: DateTimeHandler.getDateTime(), calculated: true, cal_status: true}) end)
            |> Enum.with_index
            |> Enum.reduce(multi, fn({ x, i }, acc) -> acc |> Multi.update("#{Integer.to_string(i)} valid", x) end)

          # 加入库存修改操作
          change_amount = valid_sc_list |> Enum.reduce(0, fn(sc, acc) -> acc + sc.amount end)
          depot_changeset = OilDepot.changeset(oildepot, %{number: oildepot.number + change_amount})
          multi_withvalid_godown = multi_withvalid |> Multi.update("update depot",depot_changeset)

          # 加入无法计算的StockChange的”修改操作“，并执行事务
          multi_withall = sc_list
            |> Enum.reduce([], fn(sc, acc) -> 
                                  case (sc.model == oildepot.kind) do
                                    true -> acc
                                    false -> [sc | acc]
                                  end
                                
                                end)
            |> Enum.map(fn(invalidsc) ->  StockChange.changeset(invalidsc, %{ date: DateTimeHandler.getDateTime(), calculated: true, cal_status: false}) end)
            |> Enum.with_index
            |> Enum.reduce(multi_withvalid_godown, fn({ x, i }, acc) -> acc |> Multi.update("#{Integer.to_string(i)} invalid", x) end)
  
          Repo.transaction(multi_withall)
      end 
    end




  
  end
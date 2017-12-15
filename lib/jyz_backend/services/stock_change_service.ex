defmodule JyzBackend.StockChangeService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{Repo, StockChange, DateTimeHandler}
    alias Ecto.Multi
  
    def create(changeset) do
      Repo.insert(changeset)
    end
    
    def page(cno \\ "", warehouse \\ "",type \\ "",sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{cno}%"
     
      query = from u in StockChange,
                    where: like(u.cno , ^like_term),
                    order_by: ^sort_by

      

      query |> Repo.paginate(page: page, page_size: page_size)
       
      


    end
  

  
    def update(changeset) do
      Repo.update(changeset)
    end

    # 查询某一仓库的库存变化，供计算库存使用
    def find_stock_change_from_oildepot(oildepotname) do
      query = from sc in StockChange,
                where: sc.warehouse == ^oildepotname,
                where: sc.calculated == false
      Repo.all(query)
    end

    # 在计算过库存后，将未能计算的库存全部更新为计算失败状态
    def markInvalid() do
      multi = Multi.new
      query = from sc in StockChange,
        where: sc.calculated == false
      Repo.all(query)
        |> Enum.map(fn(sc) -> StockChange.changeset(sc, %{ date: DateTimeHandler.getDateTime(), calculated: true, cal_status: false}) end)
        |> Enum.with_index
        |> Enum.reduce(multi, fn({ x, i }, acc) -> acc |> Multi.update("#{Integer.to_string(i)} flush_invalid", x) end)
        |> Repo.transaction
    end


  
  end
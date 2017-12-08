defmodule JyzBackend.ContractForPurchaseService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{ContractForPurchase, ContractForPurchaseDetail, UserService, Repo}
  
    def page(cno \\ "", audited \\ "null",sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{cno}%"
    
      query = from u in ContractForPurchase,
                  where: like(u.cno , ^like_term),
                  order_by: ^sort_by,
                  preload: [:contract_for_purchase_details]
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
                              |> Enum.map(fn(c) -> Map.drop(c, [:contract_for_purchase_details]) end)}
        true ->
          page
      end
  
    end
    
    def getById(id) do
      Repo.one from c in ContractForPurchase,
            where: c.id == ^id,
            preload: [:contract_for_purchase_details] 
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
  
  
end
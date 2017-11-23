defmodule JyzBackend.ContractForPurchaseService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{ContractForPurchase, ContractForPurchaseDetail, UserService, Repo}
  
    def page(cno \\ "", sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{cno}%"
    
      query = from u in ContractForPurchase,
                  where: like(u.cno , ^like_term),
                  order_by: ^sort_by,
                  preload: [:contract_for_purchase_details]
    
      page = query |> Repo.paginate(page: page, page_size: page_size)
        
      cond do
        page.entries > 0 ->
          %{page | entries: page.entries 
                              |> Enum.map(fn(c) -> Map.drop(c, [:contract_for_purchase_details]) end)
                              |> Enum.map(fn(c) -> Map.update("creater", "", &(UserService.getUsername(&1))) end)}
        true ->
          page
      end
  
    end
    
    def getById(id) do
      c = Repo.one from c in ContractForPurchase,
            where: c.id == ^id,
            preload: [:contract_for_purchase_details] 
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
  
  
end
defmodule JyzBackend.OilTransferService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{OilTransfer, OilTransferDetail, Repo}
  
    def page(billno \\ "", sort_field \\ "date", sort_direction \\ "desc", page \\ 1, page_size \\ 20) do 
  
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{billno}%"
    
      query = from u in OilTransfer,
                  where: like(u.billno , ^like_term),
                  order_by: ^sort_by,
                  preload: [:oil_transfer_details]
    
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
  
  
  end
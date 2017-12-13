defmodule JyzBackend.OilDepotService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{OilDepot, Repo}
  
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
  
  end
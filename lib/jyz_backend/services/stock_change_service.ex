defmodule JyzBackend.StockChangeService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{Repo, StockChange}
  
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
       
    #   cond do
    #     page.entries > 0 ->
    #       %{page | entries: page.entries |> Enum.map(fn(u) -> Map.drop(u, [:password_hash, :password]) end)}
    #     true ->
    #       page
    #   end
    end
  
    # def delete(sc) do
    #   Repo.delete!(sc) 
    # end
  
    def update(changeset) do
      Repo.update(changeset)
    end
  
    # def getById(id) do
    #   Repo.get(User, id)
    # end
  
    # def getByName(name) do
    #   Repo.get_by(User, username: name)
    # end

    # def getUsernameById(id) do
    #   case Repo.get(User, id) do
    #     nil -> ""
    #     u -> u.username
    #   end
    # end

    # def getUsernameById() do
    #   ""
    # end
  
  end
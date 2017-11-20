defmodule JyzBackend.UserService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    import Ecto.Query.API, only: [like: 2]
    alias JyzBackend.{User, Repo}
  
    def create(changeset) do
      Repo.insert(changeset)
    end
    
    def page(username \\ "", sort_field \\ "username", sort_direction \\ "asc", page \\ 1, page_size \\ 20) do 
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{username}%"
      query = from u in User,
                    where: like(u.username , ^like_term),
                    order_by: ^sort_by
      page = query |> Repo.paginate(page: page, page_size: page_size)  
      cond do
        page.entries > 0 ->
          %{page | entries: page.entries |> Enum.map(fn(u) -> Map.drop(u, [:password_hash, :password]) end)}
        true ->
          page
      end
    end
  
    def delete(user) do
      Repo.delete!(user) 
        |> Map.drop([:password_hash, :password])
    end
  
    def update(changeset) do
      Repo.update(changeset)
    end
  
    def getById(id) do
      Repo.get(User, id)
    end
  
    def getByName(name) do
      Repo.get_by(User, username: name)
    end
  
  end
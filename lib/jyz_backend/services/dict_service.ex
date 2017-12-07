defmodule JyzBackend.DictService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    alias JyzBackend.{Dict, Repo}
  
    def create(changeset) do
      Repo.insert(changeset)
    end
    
    def page(code \\ "", sort_field \\ "seq", sort_direction \\ "asc", page \\ 1, page_size \\ 20) do 
      sort_by = [{sort_direction |> String.to_existing_atom, sort_field |> String.to_existing_atom}]
      like_term = "%#{code}%"
      query = from u in Dict,
                    where: like(u.code , ^like_term),
                    order_by: ^sort_by
      page = query |> Repo.paginate(page: page, page_size: page_size)  
      cond do
        page.entries > 0 ->
          %{page | entries: page.entries}
        true ->
          page
        end
    end
  
    def delete(dict) do
      Repo.delete!(dict) 
    end
  
    def update(changeset) do
      Repo.update(changeset)
    end
  
    def getById(id) do
      Repo.get(Dict, id)
    end
  
    # def getByName(name) do
    #   Repo.get_by(User, username: name)
    # end
  
  end
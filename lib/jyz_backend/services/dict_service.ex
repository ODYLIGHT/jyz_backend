defmodule JyzBackend.DictService do
    use Ecto.Schema
    import Ecto.Query, only: [from: 2]
    alias JyzBackend.{Dict, Repo}
  
    def create(changeset) do
      d = Repo.insert(changeset)
      flushDict() 
      d
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
      d = Repo.delete!(dict) 
      flushDict() 
      d
    end
  
    def update(changeset) do
      d = Repo.update(changeset)
      flushDict()
      d
    end
  
    def getById(id) do
      Repo.get(Dict, id)
    end
  
    # def getByName(name) do
    #   Repo.get_by(User, username: name)
    # end

    # 获取数据字典内容用以缓存
    def getDictMap() do
      Repo.all(Dict) 
        |> Enum.reduce(%{}, fn(d, acc) -> acc |> Map.put(d.key, d.parm) end)
    end

    # 刷新内存中数据字典
    def flushDict() do
      m = getDictMap()
      GenServer.cast(AppDict, {:set_dict, m})
    end
  
end
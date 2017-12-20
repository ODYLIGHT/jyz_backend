defmodule JyzBackendWeb.DictController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{Dict, DictService, Permissions}
    def index(conn, params) do
      name = Map.get(params, "name", "")
      sort_field = Map.get(params, "sort_field", "key")
      sort_direction = Map.get(params, "sort_direction", "asc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
       json conn, DictService.page(name,sort_field,sort_direction,page,page_size) 
    end
  
   def new(conn, %{"dict" => dict_params}) do
      dict_changeset = Dict.changeset(%Dict{}, dict_params)
      case DictService.create(dict_changeset) do
        {:ok, dict} ->
          json conn, dict
        {:error, changeset} ->
          json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
      end
    end
  
    def delete(conn, %{"id" => id}) do
    checkperm = Permissions.hasAllPermissions(conn, [:all_something]) 
      case { checkperm,DictService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "Unauthorized operation."}
        { true, nil } ->
          json conn , %{error: "can not find dict"}
        { true, dict } ->
          json conn, DictService.delete(dict)
      end
    end

     def show(conn, %{"id" => id}) do
    case DictService.getById(id) do
      nil ->
        json conn, %{error: "can not find dict"}
      dict ->
        IO.puts inspect dict
        json conn, dict 
    end
  end
  
    def update(conn, %{"id" => id, "dict" => dict_params}) do
      checkperm = Permissions.hasAllPermissions(conn, [:all_something]) 
      case checkperm do
        true ->
          dict=DictService.getById(id)
          dict_changeset = Dict.changeset(dict, dict_params)
          case DictService.update(dict_changeset) do
            {:ok, dict} ->
              json conn, dict
            {:error, changeset} ->
              json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
          end
        false -> json conn, %{error: "Unauthorized operation."}
      end
    end
      
      # 获取当前登录用户
  defp get_current_user(conn) do
    conn.private.guardian_default_resource
  end
end
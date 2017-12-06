defmodule JyzBackendWeb.OilDepotController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{OilDepot, OilDepotService, 
                        Repo, ResolveAssociationRecursion, Permissions}
    #alias Phoenix.ActionClauseErrorr
    use Ecto.Schema
    
    def index(conn, params) do                                            #查询
      depotname = Map.get(params, "depotname", "")
      sort_field = Map.get(params, "sort_field", "depotiddr")
      sort_direction = Map.get(params, "sort_direction", "desc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
      json conn, OilDepotService.page(depotname,sort_field,sort_direction,page,page_size) 
    end
    
    def show(conn, %{"id" => id}) do                                      #单个查询
      case OilDepotService.getById(id) do
        nil ->
          json conn, %{error: "can not find 仓库"}
        od ->
          IO.puts inspect od
          json conn, od #|>ResolveAssociationRecursion.resolve_recursion_in_map(:oil_depot)
      end
    end
    

    def new(conn, %{"oildepot" => od_params}) do                           #增加
      od_changeset = OilDepot.changeset(%OilDepot{}, od_params)
    #   case Map.get(od_params, "details") do
    #     nil ->
    #       details = []
    #     map ->
    #       details = map 
    #         |> Enum.map(fn(m) -> OilTransferDetail.changeset(%OilTransferDetail{}, m) end)
    #   end
    #  ot_with_details = Ecto.Changeset.put_assoc(ot_changeset, :oil_transfer_details, details)
    # oildepots = Ecto.Changeset.put_assoc(od_changeset)
      case OilDepotService.create(od_changeset) do
        {:ok, od} ->
          json conn, od
        {:error, changeset} ->
          json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
      end
    end
    
    def delete(conn, %{"id" => id}) do #删除
     checkperm = Permissions.hasAllPermissions(conn, [:all_something])
      case { checkperm, OilDepotService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "越权操作"}
        { true, nil } ->
          json conn , %{error: "Can not find 油品仓库"}
        { true, c } ->
          case OilDepotService.delete(c) do
            {:ok, c} ->
              json conn, c
            {:error, _} ->
              json conn , %{error: "Something wrong 想不到吧?(我也想不到)"}
          end
      end
    end
    
    def update(conn, %{"id" => id, "oildepot" => od_params}) do #修改
      od = OilDepotService.getById(id)
      od_changeset = OilDepot.changeset(od, od_params)
    #   details = Map.get(ot_params,"details")
    #   case details do
    #     nil ->
    #       details = []
    #     details
    #       details = details |> Enum.map(fn(m) -> OilTransferDetail.changeset(%OilTransferDetail{}, m) end)
    #   end
    #  oildepots = Ecto.Changeset.put_assoc(od_changeset)
      case OilDepotService.update(od_changeset) do
        {:ok, ot} ->
          json conn, ot
        {:error, changeset} ->
          json conn , %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
      end
    end
  
    # 获取当前登录用户
    defp get_current_user(conn) do
      conn.private.guardian_default_resource
    end
end

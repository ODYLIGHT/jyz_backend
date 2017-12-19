defmodule JyzBackendWeb.OilTransferController do
    use JyzBackendWeb, :controller
    alias JyzBackend.{OilTransfer, OilTransferDetail, OilTransferService, DateTimeHandler,
                        Repo, ResolveAssociationRecursion, Permissions,Guardian}
    #alias Phoenix.ActionClauseErrorr
    use Ecto.Schema

    def index(conn, params) do #查询

      DateTimeHandler.getDateTime()
      
      billno = Map.get(params, "billno", "")
      audited = Map.get(params, "audited", "")
      sort_field = Map.get(params, "sort_field", "date")
      sort_direction = Map.get(params, "sort_direction", "desc")
      page = Map.get(params, "page", 1)
      page_size = Map.get(params, "page_size", 20)
      json conn, OilTransferService.page(billno,audited,sort_field,sort_direction,page,page_size) 
      IO.puts inspect audited
    end
    
    def show(conn, %{"id" => id}) do #单个查询
      case OilTransferService.getById(id) do
        nil ->
          json conn, %{error: "can not find 油品"}
        ot -> 
          IO.puts inspect ot
          json conn, ot |>ResolveAssociationRecursion.resolve_recursion_in_map(:oil_transfer_details, :oil_transfer)
      end
    end
    
    def new(conn, %{"oiltransfer" => ot_params}) do #增加
       # 创建时，“已审核”（audited）字段设置为false
       ot_changeset = OilTransfer.changeset(%OilTransfer{}, ot_params 
              |> Map.update("audited", false,fn(a) -> false end )
              |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
      case Map.get(ot_params, "details") do
        nil ->
          details = []
        map ->
          details = map 
            |> Enum.map(fn(m) -> OilTransferDetail.changeset(%OilTransferDetail{}, m) end)
      end
      ot_with_details = Ecto.Changeset.put_assoc(ot_changeset, :oil_transfer_details, details)
      case OilTransferService.create(ot_with_details) do
        {:ok, ot} ->
          json conn, ot |> Map.drop([:oil_transfer_details])
        {:error, changeset} ->
          json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
      end
    end
    
    def delete(conn, %{"id" => id}) do #删除
      checkperm = Permissions.hasAllPermissions(conn, [:all_something])
      case { checkperm, OilTransferService.getById(id) } do
        { false, _ } ->
          json conn, %{error: "越权操作"}
        { true, nil } ->
          json conn , %{error: "Can not find 油品移库表"}
        { true, c } ->         
          case OilTransferService.delete(c) do
            {:ok, c} ->
              json conn, c |> Map.drop([:oil_transfer_details])
            {:error, _} ->
              json conn , %{error: "Something wrong"}
          end
      end
    end
    
    def update(conn, %{"id" => id, "oiltransfer" => ot_params}) do #修改   

    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, OilTransferService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find OilTransfer"}
      { true, ot } ->

        ot = OilTransferService.getById(id)
        ot_changeset = OilTransfer.changeset(ot, ot_params 
                                                         |> Map.update("audited", ot.audited, fn(c) -> ot.audited end)
                                                         |> Map.update("audit_time", ot.audit_time, fn(c) -> ot.audit_time end)
                                                         |> Map.update("audit_user", ot.audit_user, fn(c) -> ot.audit_user end)
                                                         |> Map.update("create_user", ot.create_user, fn(c) -> ot.create_user end))
     

      details = Map.get(ot_params,"details")
      case details do
        nil ->
          details = []
        details ->
          details = details |> Enum.map(fn(m) -> OilTransferDetail.changeset(%OilTransferDetail{}, m) end)
      end

      ot_with_details = Ecto.Changeset.put_assoc(ot_changeset, :oil_transfer_details, details)
      case OilTransferService.update(ot_with_details) do
        {:ok, ot} ->
          json conn, ot |> Map.drop([:oil_transfer_details])
        {:error, changeset} ->
          json conn |> put_status(500), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
       end

     end

    end
  
    # 获取当前登录用户
    defp get_current_user(conn) do
      conn.private.guardian_default_resource
    end


     # 油品移库审核
    def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, OilTransferService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find OilTransfer"}
      {true, c } ->
        case c.audited do
          false ->
            ot_changeset = OilTransfer.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case OilTransferService.auditStockIn(c, ot_changeset) do
              {:ok, c} ->
                json conn, c["audit"] |> Map.drop([:oil_transfer_details])
              {:error, _,_,_} ->
                json conn, %{error: "Audit failed, please check details."}
            end
          true ->
            json conn , %{error: "OilTransfer has already been audited."}
        end
    end

  end

end
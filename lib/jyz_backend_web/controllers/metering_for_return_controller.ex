defmodule JyzBackendWeb.MeteringForReturnController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{MeteringForReturn, MeteringForReturnDetail, MeteringForReturnService, 
                      DateTimeHandler,Repo, ResolveAssociationRecursion, Permissions,Guardian}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do
    DateTimeHandler.getDateTime()
    
    billno = Map.get(params, "billno", "")
    sort_field = Map.get(params, "sort_field", "billdate")
    sort_direction = Map.get(params, "sort_direction", "desc")
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 20)
    json conn, MeteringForReturnService.page(billno,sort_field,sort_direction,page,page_size) 
  end
  
  def show(conn, %{"id" => id}) do
    case MeteringForReturnService.getById(id) do
      nil ->
        json conn, %{error: "can not find metering"}
      cfp ->
        json conn, cfp |>ResolveAssociationRecursion.resolve_recursion_in_map(:metering_for_return_details, :metering_for_return)
    end
  end
  
  def new(conn, %{"meteringforreturn" => cfp_params}) do
    # 创建时，“已审核”（audited）字段设置为false
    cfp_changeset = MeteringForReturn.changeset(%MeteringForReturn{}, 
                                                cfp_params 
                                                      |> Map.update("audited", false, fn(a) -> false end)
                                                      |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
    case Map.get(cfp_params, "details") do
      nil ->
        details = []
      map ->
        details = map 
          |> Enum.map(fn(m) -> MeteringForReturnDetail.changeset(%MeteringForReturnDetail{}, m) end)
    end
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :metering_for_return_details, details)
    case MeteringForReturnService.create(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:metering_for_return_details])
      {:error, changeset} ->
        json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
  
  def delete(conn, %{"id" => id}) do 
    checkperm = Permissions.hasAllPermissions(conn, [:all_something])
    case { checkperm, MeteringForReturnService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find Metering_For_Return"}
      { true, c } ->
        case MeteringForReturnService.delete(c) do
          {:ok, c} ->
            json conn, c |> Map.drop([:metering_for_return_details])
          {:error, _} ->
            json conn , %{error: "Something wrong"}
        end
    end
  end
  
 def update(conn, %{"id" => id, "meteringforreturn" => cfp_params}) do


    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, MeteringForReturnService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find MeteringForReturn"}
      { true, cfp } ->
        

        cfp = MeteringForReturnService.getById(id)
        cfp_changeset = MeteringForReturn.changeset(cfp, cfp_params 
                                                         |> Map.update("audited", cfp.audited, fn(c) -> cfp.audited end)
                                                         |> Map.update("audit_time", cfp.audit_time, fn(c) -> cfp.audit_time end)
                                                         |> Map.update("audit_user", cfp.audit_user, fn(c) -> cfp.audit_user end)
                                                         |> Map.update("create_user", cfp.create_user, fn(c) -> cfp.create_user end))
        details = Map.get(cfp_params, "details") 
        case details do
          nil ->
            details = []
          details ->
            details = details |> Enum.map(fn(m) -> MeteringForReturnDetail.changeset(%MeteringForReturnDetail{}, m) end)
        end
        cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :metering_for_return_details, details)
        case MeteringForReturnService.update(cfp_with_details) do
          {:ok, cfp} ->
            json conn, cfp |> Map.drop([:metering_for_return_details])
          {:error, changeset} ->
            json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
        end

    end

  end
  # 油品回罐审核
  def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, MeteringForReturnService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find MeteringForReturn"}
      {true, c } ->
        case c.audited do
          false ->
            cfp_changeset = MeteringForReturn.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case MeteringForReturnService.update(cfp_changeset) do
              {:ok, c} ->
                json conn, c |> Map.drop([:metering_for_return_details])
              {:error, changeset} ->
                json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
            end
          true ->
            json conn , %{error: "MeteringForReturn has already been audited."}
        end
    end

  end

end
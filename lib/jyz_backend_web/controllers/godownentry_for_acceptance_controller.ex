defmodule JyzBackendWeb.GodownentryForAcceptanceController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{GodownentryForAcceptance, GodownentryForAcceptanceDetail, GodownentryForAcceptanceService, 
                     DateTimeHandler,ResolveAssociationRecursion, Permissions,Guardian}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do
    bno = Map.get(params, "bno", "")
    audited = Map.get(params, "audited", "")
    # supplier=Map.get(params,"")
    sort_field = Map.get(params, "sort_field", "cno")
    sort_direction = Map.get(params, "sort_direction", "desc")
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 20)
    json conn, GodownentryForAcceptanceService.page(bno,audited,sort_field,sort_direction,page,page_size) 
  end
  
  
  def show(conn, %{"id" => id}) do
    case GodownentryForAcceptanceService.getById(id) do
      nil ->
        json conn, %{error: "can not find Godownentry"}
      cfp ->
        IO.puts inspect cfp
        json conn, cfp |>ResolveAssociationRecursion.resolve_recursion_in_map(:godownentry_for_acceptance_details, :godownentry_for_acceptance)
    end
  end
  
  def new(conn, %{"godownentryforacceptance" => cfp_params}) do
  # 创建时，“已审核”（audited）字段设置为false
    cfp_changeset = GodownentryForAcceptance.changeset(%GodownentryForAcceptance{}, cfp_params |> Map.update("audited", false, fn(a) -> false end)
                                                      |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
                              
    case Map.get(cfp_params, "details") do
      nil ->
        details = []
      map ->
        details = map 
          |> Enum.map(fn(m) -> GodownentryForAcceptanceDetail.changeset(%GodownentryForAcceptanceDetail{}, m) end)
    end
    IO.puts inspect details
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :godownentry_for_acceptance_details, details)
    case GodownentryForAcceptanceService.create(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:godownentry_for_acceptance_details])
      {:error, changeset} ->
        json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
  
  def delete(conn, %{"id" => id}) do 
    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, GodownentryForAcceptanceService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find Godownentry_For_Acceptance"}
      { true, c } ->
        case GodownentryForAcceptanceService.delete(c) do
          {:ok, c} ->
            json conn, c |> Map.drop([:godownentry_for_acceptance_details])
          {:error, _} ->
            json conn , %{error: "Something wrong"}
        end
    end
  end
  
  def update(conn, %{"id" => id, "godownentryforacceptance" => cfp_params}) do
checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, GodownentryForAcceptanceService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find GodownentryForAcceptance"}
      { true, cfp } ->


    cfp = GodownentryForAcceptanceService.getById(id)
        cfp_changeset = GodownentryForAcceptance.changeset(cfp, cfp_params 
                                                         |> Map.update("audited", cfp.audited, fn(c) -> cfp.audited end)
                                                         |> Map.update("audit_time", cfp.audit_time, fn(c) -> cfp.audit_time end)
                                                         |> Map.update("audit_user", cfp.audit_user, fn(c) -> cfp.audit_user end)
                                                         |> Map.update("create_user", cfp.create_user, fn(c) -> cfp.create_user end))
    details = Map.get(cfp_params, "details")
   case details do
        nil ->
          details = []
        details ->
          details =details |> Enum.map(fn(m) -> GodownentryForAcceptanceDetail.changeset(%GodownentryForAcceptanceDetail{}, m) end)
          end
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :godownentry_for_acceptance_details, details)
    case GodownentryForAcceptanceService.update(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:godownentry_for_acceptance_details])
      {:error, changeset} ->
        json conn |> put_status(500), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
end
 
  # 油品入库检验审核
  def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, GodownentryForAcceptanceService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find GodownentryForAcceptance"}
      {true, c } ->
        case c.audited do
          false ->
            cfp_changeset = GodownentryForAcceptance.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case GodownentryForAcceptanceService.auditStockIn(c, cfp_changeset) do
              {:ok, c} ->
                json conn, c["audit"] |> Map.drop([:godownentry_for_acceptance_details])
              {:error, a,b,c} ->
                IO.puts("##### print error #####")
                IO.puts inspect a
                IO.puts inspect b
                IO.puts inspect c
                json conn, %{error: "Audit failed, please check details."}
            end
          true ->
            json conn , %{error: "GodownentryForAcceptance has already been audited."}
        end
    end
  end

end        
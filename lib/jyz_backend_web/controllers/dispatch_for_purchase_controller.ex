defmodule JyzBackendWeb.DispatchForPurchaseController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{DispatchForPurchase, DispatchForPurchaseDetail, DispatchForPurchaseService, 
                      DateTimeHandler,Repo, ResolveAssociationRecursion, Permissions,Guardian}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do
    DateTimeHandler.getDateTime()
    billno = Map.get(params, "billno", "")
    # date = Map.get(params, "date", "")
    # audited = Map.get(params, "audited", "")
    sort_field = Map.get(params, "sort_field", "date")
    sort_direction = Map.get(params, "sort_direction", "desc")
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 20)
    json conn, DispatchForPurchaseService.page(billno,sort_field,sort_direction,page,page_size) 
  end
  
  def show(conn, %{"id" => id}) do
    case DispatchForPurchaseService.getById(id) do
      nil ->
        json conn, %{error: "can not find dispatch"}
      cfp ->
        IO.puts inspect cfp
        json conn, cfp |>ResolveAssociationRecursion.resolve_recursion_in_map(:dispatch_for_purchase_details, :dispatch_for_purchase)
    end
  end
  
  def new(conn, %{"dispatchforpurchase" => cfp_params}) do
    cfp_changeset = DispatchForPurchase.changeset(%DispatchForPurchase{}, 
                                                    cfp_params 
                                                      |> Map.update("audited", false,fn(a)->false end)
                                                      |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
    case Map.get(cfp_params, "details") do
      nil ->
        details = []
      map ->
        details = map 
          |> Enum.map(fn(m) -> DispatchForPurchaseDetail.changeset(%DispatchForPurchaseDetail{}, m) end)
    end
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :dispatch_for_purchase_details, details)
    case DispatchForPurchaseService.create(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:dispatch_for_purchase_details])
      {:error, changeset} ->
        json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
  
  def delete(conn, %{"id" => id}) do 
    checkperm = Permissions.hasAllPermissions(conn, [:all_something])
    case { checkperm, DispatchForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find Dispatch_For_Purchase"}
      { true, c } ->
        case DispatchForPurchaseService.delete(c) do
          {:ok, c} ->
            json conn, c |> Map.drop([:dispatch_for_purchase_details])
          {:error, _} ->
            json conn , %{error: "Something wrong"}
        end
    end
  end
  
  def update(conn, %{"id" => id, "dispatchforpurchase" => cfp_params}) do
    # try do

    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, DispatchForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find DispatchForPurchase"}
      { true, cfp } ->
        

        cfp = DispatchForPurchaseService.getById(id)
        cfp_changeset = DispatchForPurchase.changeset(cfp, cfp_params 
                                                         |> Map.update("audited", cfp.audited, fn(c) -> cfp.audited end)
                                                         |> Map.update("audit_time", cfp.audit_time, fn(c) -> cfp.audit_time end)
                                                         |> Map.update("audit_user", cfp.audit_user, fn(c) -> cfp.audit_user end)
                                                         |> Map.update("create_user", cfp.create_user, fn(c) -> cfp.create_user end))
        details = Map.get(cfp_params, "details") 
        case details do
          nil ->
            details = []
          details ->
            details = details |> Enum.map(fn(m) -> DispatchForPurchaseDetail.changeset(%DispatchForPurchaseDetail{}, m) end)
        end
        cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :dispatch_for_purchase_details, details)
        case DispatchForPurchaseService.update(cfp_with_details) do
          {:ok, cfp} ->
            json conn, cfp |> Map.drop([:dispatch_for_purchase_details])
          {:error, changeset} ->
            json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
        end

    end

  end
   
    
# 油品配送出库单审核
  def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, DispatchForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find DispatchForPurchase"}
      {true, c } ->
        case c.audited do
          false ->
            cfp_changeset = DispatchForPurchase.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case DispatchForPurchaseService.update(cfp_changeset) do
              {:ok, c} ->
                json conn, c |> Map.drop([:dispatch_for_purchase_details])
              {:error, changeset} ->
                json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
            end
          true ->
            json conn , %{error: "DispatchForPurchase has already been audited."}
        end
    end

  end

end
  

  


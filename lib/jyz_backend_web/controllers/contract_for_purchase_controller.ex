defmodule JyzBackendWeb.ContractForPurchaseController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{ContractForPurchase, ContractForPurchaseDetail, ContractForPurchaseService, 
                      DateTimeHandler, Repo, ResolveAssociationRecursion, Permissions, Guardian}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do

    DateTimeHandler.getDateTime()
    
    cno = Map.get(params, "cno", "")
    sort_field = Map.get(params, "sort_field", "date")
    sort_direction = Map.get(params, "sort_direction", "desc")
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 20)
    json conn, ContractForPurchaseService.page(cno,sort_field,sort_direction,page,page_size) 
  end
  
  def show(conn, %{"id" => id}) do
    case ContractForPurchaseService.getById(id) do
      nil ->
        json conn, %{error: "can not find contract"}
      cfp ->
        json conn, cfp |> ResolveAssociationRecursion.resolve_recursion_in_map(:contract_for_purchase_details, :contract_for_purchase)
    end
  end
  
  def new(conn, %{"contractforpurchase" => cfp_params}) do
    # 创建时，“已审核”（audited）字段设置为false
    cfp_changeset = ContractForPurchase.changeset(%ContractForPurchase{}, 
                                                    cfp_params 
                                                      |> Map.update("audited", false, fn(a) -> false end)
                                                      |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
    case Map.get(cfp_params, "details") do
      nil ->
        details = []
      map ->
        details = map 
          |> Enum.map(fn(m) -> ContractForPurchaseDetail.changeset(%ContractForPurchaseDetail{}, m) end)
    end
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :contract_for_purchase_details, details)
    case ContractForPurchaseService.create(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:contract_for_purchase_details])
      {:error, changeset} ->
        json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
  
  def delete(conn, %{"id" => id}) do 
    checkperm = Permissions.hasAllPermissions(conn, [:all_something])
    case { checkperm, ContractForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find Contract_For_Purchase"}
      { true, c } ->
        case ContractForPurchaseService.delete(c) do
          {:ok, c} ->
            json conn, c |> Map.drop([:contract_for_purchase_details])
          {:error, _} ->
            json conn , %{error: "Something wrong"}
        end
    end
  end
  
  def update(conn, %{"id" => id, "contractforpurchase" => cfp_params}) do


    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, ContractForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find ContractForPurchase"}
      { true, cfp } ->
        

        cfp = ContractForPurchaseService.getById(id)
        cfp_changeset = ContractForPurchase.changeset(cfp, cfp_params 
                                                         |> Map.update("audited", cfp.audited, fn(c) -> cfp.audited end))
        details = Map.get(cfp_params, "details") 
        case details do
          nil ->
            details = []
          details ->
            details = details |> Enum.map(fn(m) -> ContractForPurchaseDetail.changeset(%ContractForPurchaseDetail{}, m) end)
        end
        cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :contract_for_purchase_details, details)
        case ContractForPurchaseService.update(cfp_with_details) do
          {:ok, cfp} ->
            json conn, cfp |> Map.drop([:contract_for_purchase_details])
          {:error, changeset} ->
            json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
        end

    end

  end

  # 采购合同审核
  def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, ContractForPurchaseService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find ContractForPurchase"}
      {true, c } ->
        case c.audited do
          false ->
            cfp_changeset = ContractForPurchase.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case ContractForPurchaseService.update(cfp_changeset) do
              {:ok, c} ->
                json conn, c |> Map.drop([:contract_for_purchase_details])
              {:error, changeset} ->
                json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
            end
          true ->
            json conn , %{error: "ContractForPurchase has already been audited."}
        end
    end

  end

end
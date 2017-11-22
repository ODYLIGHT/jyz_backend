defmodule JyzBackendWeb.ContractForPurchaseController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{ContractForPurchase, ContractForPurchaseDetail, ContractForPurchaseService, 
                      Repo, ResolveAssociationRecursion, Permissions}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do
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
        IO.puts inspect cfp
        json conn, cfp |>ResolveAssociationRecursion.resolve_recursion_in_map(:contract_for_purchase_details, :contract_for_purchase)
    end
  end
  
  def new(conn, %{"contractforpurchase" => cfp_params}) do
    cfp_changeset = ContractForPurchase.changeset(%ContractForPurchase{}, cfp_params)
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
    # try do

    cfp = ContractForPurchaseService.getById(id)
    cfp_changeset = ContractForPurchase.changeset(cfp, cfp_params)
    details = Map.get(cfp_params, "details") |> Enum.map(fn(m) -> ContractForPurchaseDetail.changeset(%ContractForPurchaseDetail{}, m) end)
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :contract_for_purchase_details, details)
    case ContractForPurchaseService.update(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:contract_for_purchase_details])
      {:error, changeset} ->
        json conn |> put_status(500), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end

    # rescue
    #   e -> json conn , %{error: "########################"}
    # catch
    #   e -> json conn , %{error: "########################"}
    # end

  end

  # 获取当前登录用户
  defp get_current_user(conn) do
    conn.private.guardian_default_resource
  end

end
defmodule JyzBackendWeb.CarryForAccountController do
  use JyzBackendWeb, :controller
  alias JyzBackend.{CarryForAccount, CarryForAccountDetail, CarryForAccountService, 
                      DateTimeHandler, Repo, ResolveAssociationRecursion, Permissions, Guardian}
  #alias Phoenix.ActionClauseErrorr
  use Ecto.Schema
  
  def index(conn, params) do

    DateTimeHandler.getDateTime()
    
    companyname = Map.get(params, "companyname", "")
    sort_field = Map.get(params, "sort_field", "date")
    sort_direction = Map.get(params, "sort_direction", "desc")
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 20)
    json conn, CarryForAccountService.page(companyname,sort_field,sort_direction,page,page_size) 
  end
  
  def show(conn, %{"id" => id}) do
    case CarryForAccountService.getById(id) do
      nil ->
        json conn, %{error: "can not find carryforaccount"}
      cfp ->
        json conn, cfp |> ResolveAssociationRecursion.resolve_recursion_in_map(:carry_for_account_details, :carry_for_account)
    end
  end
  
  def new(conn, %{"carryforaccount" => cfp_params}) do
    # 创建时，“已审核”（audited）字段设置为false
    cfp_changeset = CarryForAccount.changeset(%CarryForAccount{}, 
                                                    cfp_params 
                                                      |> Map.update("audited", false, fn(a) -> false end)
                                                      |> Map.update("create_user", Guardian.resource_name_from_conn(conn), fn(c) -> Guardian.resource_name_from_conn(conn) end))
    case Map.get(cfp_params, "details") do
      nil ->
        details = []
      map ->
        details = map 
          |> Enum.map(fn(m) -> CarryForAccountDetail.changeset(%CarryForAccountDetail{}, m) end)
    end
    cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :carry_for_account_details, details)
    case CarryForAccountService.create(cfp_with_details) do
      {:ok, cfp} ->
        json conn, cfp |> Map.drop([:carry_for_account_details])
      {:error, changeset} ->
        json conn |> put_status(200), %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
    end
  end
  
  def delete(conn, %{"id" => id}) do 
    checkperm = Permissions.hasAllPermissions(conn, [:all_something])
    case { checkperm, CarryForAccountService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find Carry_For_Account"}
      { true, c } ->
        case CarryForAccountService.delete(c) do
          {:ok, c} ->
            json conn, c |> Map.drop([:carry_for_account_details])
          {:error, _} ->
            json conn , %{error: "Something wrong"}
        end
    end
  end
  
  def update(conn, %{"id" => id, "carryforaccount" => cfp_params}) do

    checkperm = Permissions.hasAllPermissions(conn, [:modify_something])
    case { checkperm, CarryForAccountService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find CarryForAccount"}
      { true, cfp } ->
        

        cfp = CarryForAccountService.getById(id)
        cfp_changeset = CarryForAccount.changeset(cfp, cfp_params 
                                                         |> Map.update("audited", cfp.audited, fn(c) -> cfp.audited end))
        details = Map.get(cfp_params, "details") 
        case details do
          nil ->
            details = []
          details ->
            details = details |> Enum.map(fn(m) -> CarryForAccountDetail.changeset(%CarryForAccountDetail{}, m) end)
        end
        cfp_with_details = Ecto.Changeset.put_assoc(cfp_changeset, :carry_for_account_details, details)
        case CarryForAccountService.update(cfp_with_details) do
          {:ok, cfp} ->
            json conn, cfp |> Map.drop([:carry_for_account_details])
          {:error, changeset} ->
            json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
        end
    end

  end

  # 销售油品提用表审核
  def audit(conn,  %{"id" => id}) do
    
    checkperm = Permissions.hasAllPermissions(conn, [:audit_something])
    case { checkperm, CarryForAccountService.getById(id) } do
      { false, _ } ->
        json conn, %{error: "Unauthorized operation."}
      { true, nil } ->
        json conn , %{error: "Can not find CarryForAccount"}
      {true, c } ->
        case c.audited do
          false ->
            cfp_changeset = CarryForAccount.changeset(c, %{"audited" => true, "audit_time" => "#{DateTimeHandler.getDateTime()}", "audit_user" => Guardian.resource_name_from_conn(conn)})
            case CarryForAccountService.update(cfp_changeset) do
              {:ok, c} ->
                json conn, c |> Map.drop([:carry_for_account_details])
              {:error, changeset} ->
                json conn, %{error: JyzBackendWeb.ChangesetError.translate_changeset_errors(changeset.errors)}
            end
          true ->
            json conn , %{error: "CarryForAccount has already been audited."}
        end
    end

  end

end
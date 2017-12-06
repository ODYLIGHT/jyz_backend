defmodule JyzBackend.CarryForAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias JyzBackend.{User, CarryForAccount, CarryForAccountDetail}
  
  schema "carry_for_account" do
    field :companyname, :string     #公司名称
    field :date, :string            #日期
    field :responsibleperson, :string #负责人
    field :operator, :string            #经办人
    field :audited, :boolean, default: false
    field :audit_time, :string
    field :audit_user, :string
    field :create_user, :string
    has_many :carry_for_account_details, CarryForAccountDetail, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end
    
  @doc false
  def changeset(%CarryForAccount{} = carryforaccount, attrs) do
    carryforaccount
      |> cast(attrs, [:companyname, :date, :responsibleperson, :operator,  :audited, :audit_time, :audit_user, :create_user])
      |> validate_required([:companyname, :date, :responsibleperson, :operator])
      |> unique_constraint(:companyname)
      |> validate_length(:companyname, min: 4)
  end

  # 自定义验证器
  defp validate_positive_number(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, n ->
      case n > 0 do
        true -> []
        false -> [{field, options[:message] || "invalid number"}]
      end
    end)
  end

end
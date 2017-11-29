defmodule JyzBackend.MeteringForReturn do
  use Ecto.Schema
  import Ecto.Changeset
  alias JyzBackend.{MeteringForReturn, MeteringForReturnDetail}
  
  schema "metering_for_return" do
    field :billno, :string
    field :billdate, :string
    field :stockman, :string
    field :accountingclerk, :string
    field :audited, :boolean, default: false
    field :audit_time, :string
    field :audit_user, :string
    field :create_user, :string
    field :comment, :string
    has_many :metering_for_return_details, MeteringForReturnDetail, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end
    
  @doc false
  def changeset(%MeteringForReturn{} = meteringforreturn, attrs) do
    meteringforreturn
      |> cast(attrs, [:billno, :billdate, :stockman, :accountingclerk, :audited, :audit_time, :audit_user, :create_user, :comment])
      |> validate_required([:billno, :billdate, :stockman, :accountingclerk])
      |> unique_constraint(:billno)
      |> validate_length(:billno, min: 4)
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
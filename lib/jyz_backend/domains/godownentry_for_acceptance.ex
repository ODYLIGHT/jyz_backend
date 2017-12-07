defmodule JyzBackend.GodownentryForAcceptance do
  use Ecto.Schema
  import Ecto.Changeset
  alias JyzBackend.{GodownentryForAcceptance, GodownentryForAcceptanceDetail}
  
  schema "godownentry_for_acceptance" do
    field :bno, :string                #单号      
    field :supplier, :string           #供应商
    field :cno, :string                #合同号
    field :buyer, :string              #采购员
    field :examiner, :string           #验收员
    field :accountingstaff, :string    #核算员
    field :create_user, :string        #录入人
    field :audit_user, :string        #审核人
    field :audited, :boolean              #状态
    field :audit_time, :string          #审核时间
    has_many :godownentry_for_acceptance_details, GodownentryForAcceptanceDetail, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end
    
  @doc false
  def changeset(%GodownentryForAcceptance{} = godownentryforacceptance, attrs) do
    godownentryforacceptance
      |> cast(attrs, [:bno, :supplier, :cno, :buyer, :examiner, :accountingstaff, :create_user, :audit_user, :audited, :audit_time])
      |> validate_required([:bno, :supplier, :cno, :buyer, :examiner, :accountingstaff])
      |> unique_constraint(:bno)
      |> validate_length(:bno, min: 4)
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
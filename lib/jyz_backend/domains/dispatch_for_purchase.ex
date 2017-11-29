defmodule JyzBackend.DispatchForPurchase do
  use Ecto.Schema
  import Ecto.Changeset
  alias JyzBackend.{User,DispatchForPurchase, DispatchForPurchaseDetail}
  
  schema "dispatch_for_purchase" do
    field :billno, :string           
    field :date, :string             
    field :purchaser, :string        
    field :stockplace, :string       
    field :quantity, :float          
    field :total, :float             
    field :dispatcher, :string       
    field :stockman, :string         
    field :accountingclerk, :string  
    field :create_user, :string              
    field :audit_user, :string               
    field :audited, :boolean, default: false 
    field :audit_time, :string              
    has_many :dispatch_for_purchase_details, DispatchForPurchaseDetail, on_delete: :delete_all, on_replace: :delete
    timestamps()
  end
    
  @doc false
  def changeset(%DispatchForPurchase{} = dispatchforpurchase, attrs) do
    dispatchforpurchase
      |> cast(attrs, [:billno, :date, :purchaser, :stockplace, :quantity, :total,:dispatcher,:stockman,:accountingclerk,:create_user,:audit_user,:audited,:audit_time])
      |> validate_required([:billno, :date, :purchaser, :stockplace, :quantity, :total,:dispatcher,:stockman,:accountingclerk])
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
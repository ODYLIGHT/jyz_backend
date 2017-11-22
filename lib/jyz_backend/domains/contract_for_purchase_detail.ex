defmodule JyzBackend.ContractForPurchaseDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{ContractForPurchase, ContractForPurchaseDetail}
      
    schema "contract_for_purchase_details" do
      field :product, :string
      field :model, :string
      field :producer, :string
      field :amount, :float
      field :unit, :string
      field :price, :float
      field :totalprice, :float
      # 这里，ECTO将使用cfp_id作为外键列名
      belongs_to :contract_for_purchase, ContractForPurchase, on_replace: :delete
      
      timestamps()
    end
    
    def changeset(%ContractForPurchaseDetail{} = cfpd, attrs) do
      cfpd
        |> cast(attrs, [:product, :model, :producer, :amount, :unit, :price])
        |> validate_required([:product, :model, :producer, :amount, :unit, :price])
        |> set_totalprice()
    end


    defp set_totalprice(changeset) do
        case changeset do
          %Ecto.Changeset{valid?: true, changes: %{amount: amount, price: price}} ->
            put_change(changeset, :totalprice, amount * price)
          _ ->
            changeset
        end
      end
  end
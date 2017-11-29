defmodule JyzBackend.DispatchForPurchaseDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{DispatchForPurchase, DispatchForPurchaseDetail}
      
    schema "dispatch_for_purchase_details" do
      
      field :oilname, :string
      field :unit, :string
      field :startdegree, :float
      field :enddegree, :float
      field :quantity, :float
      field :confirmation, :string
      
      # 这里，ECTO将使用dispatch_for_purchase_id作为外键列名
      belongs_to :dispatch_for_purchase, DispatchForPurchase, on_replace: :delete
      
      timestamps()
    end
    
    def changeset(%DispatchForPurchaseDetail{} = cfpd, attrs) do
      cfpd
        |> cast(attrs, [:oilname, :unit, :startdegree, :enddegree, :quantity, :confirmation])
        |> validate_required([:oilname, :unit, :startdegree, :enddegree, :quantity, :confirmation])
        # |> set_totalprice()
    end


    # defp set_totalprice(changeset) do
    #     case changeset do
    #       %Ecto.Changeset{valid?: true, changes: %{amount: amount, price: price}} ->
    #         put_change(changeset, :totalprice, amount * price)
    #       _ ->
    #         changeset
    #     end
    #   end
  end
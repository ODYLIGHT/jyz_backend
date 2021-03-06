defmodule JyzBackend.OilTransferDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{OilTransfer, OilTransferDetail}
      
    schema "oil_transfer_details" do
      field :billno1, :string
      field :stockpalce, :string
      field :Unit, :string
      field :Startdegree, :float
      field :Enddegree, :float
      field :quantity, :float
      field :Confirmation, :string
      # 这里，ECTO将使用oil_transfer_id作为外键列名
      belongs_to :oil_transfer, OilTransfer, on_replace: :delete
      
      timestamps()
    end
    
    def changeset(%OilTransferDetail{} = otd, attrs) do
      otd
        |> cast(attrs, [:billno1, :stockpalce, :Unit, :Startdegree, :Enddegree, :quantity,:Confirmation])
        #|> validate_required([:product, :model, :producer, :amount, :unit, :price])
        #|> set_totalprice()
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
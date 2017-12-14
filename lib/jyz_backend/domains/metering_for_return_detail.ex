defmodule JyzBackend.MeteringForReturnDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{MeteringForReturn, MeteringForReturnDetail}
      
    schema "metering_for_return_details" do
      field :wagonno, :string
      field :cardno, :string
      field :oilname, :string
      field :unit, :string
      field :quantity, :float
      field :stockplace, :string
      field :comment, :string
      # 这里，ECTO将使用cfp_id作为外键列名
      belongs_to :metering_for_return, MeteringForReturn, on_replace: :delete
      
      timestamps()
    end
    
    def changeset(%MeteringForReturnDetail{} = cfpd, attrs) do
      cfpd
        |> cast(attrs, [:wagonno, :cardno, :oilname, :unit, :quantity, :stockplace, :comment])
        |> validate_required([:wagonno, :cardno, :oilname, :unit, :quantity, :stockplace])
        #|> set_totalprice()
    end


  #   defp set_totalprice(changeset) do
  #       case changeset do
  #         %Ecto.Changeset{valid?: true, changes: %{amount: amount, price: price}} ->
  #           put_change(changeset, :totalprice, amount * price)
  #         _ ->
  #           changeset
  #       end
  #     end
   end
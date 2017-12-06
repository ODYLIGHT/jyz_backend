defmodule JyzBackend.CarryForAccountDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{CarryForAccount, CarryForAccountDetail}
      
    schema "carry_for_account_details" do
      field :stockcompany, :string  #存货单位
      field :variety, :string       #品种 
      field :lastt, :float         #上期结存（吨）
      field :lastl, :float          #上期结存（升）
      field :stockt, :float        #本月存油（吨）
      field :stockl, :float         #本月存油（升）
      field :monthpickupt, :float   #本月提用（吨）
      field :monthpickupl, :float   #本月提用（升）
      field :monthstockt, :float    #本月结存（吨）
      field :monthstockl, :float    #本月结存（升）
    
      # 这里，ECTO将使用cfp_id作为外键列名
      belongs_to :carry_for_account, CarryForAccount, on_replace: :delete
      
      timestamps()
    end
    
    def changeset(%CarryForAccountDetail{} = cfpd, attrs) do
      cfpd
        |> cast(attrs, [:stockcompany, :variety, :lastt, :lastl, :stockt, :stockl, :monthpickupt, :monthpickupl, :monthstockt, :monthstockl])
        |> validate_required([:stockcompany, :variety, :lastt, :lastl, :stockt, :stockl, :monthpickupt, :monthpickupl, :monthstockt, :monthstockl])
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
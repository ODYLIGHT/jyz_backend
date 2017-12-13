defmodule JyzBackend.GodownentryForAcceptanceDetail do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{GodownentryForAcceptance, GodownentryForAcceptanceDetail}
      
    schema "godownentry_for_acceptance_details" do
      field :oilname, :string     #油品名称
      field :planquantity, :float #计划采购量
      field :realquantity, :float #实际采购量
      field :price, :float        #入库单价
      field :totalprice, :float   #入库金额
      field :stockplace, :string  #入库地
      field :comment, :string     #备注
      # 这里，ECTO将使用cfp_id作为外键列名
      belongs_to :godownentry_for_acceptance, GodownentryForAcceptance, on_replace: :delete
      timestamps()
    end
    
    def changeset(%GodownentryForAcceptanceDetail{} = cfpd, attrs) do
      cfpd
        |> cast(attrs, [:oilname, :planquantity, :realquantity, :price, :totalprice, :stockplace, :comment])
        |> validate_required([:oilname, :planquantity, :realquantity, :price, :stockplace])
        |> set_totalprice()
    end


    defp set_totalprice(changeset) do
        case changeset do
          %Ecto.Changeset{valid?: true, changes: %{realquantity: realquantity, price: price}} ->
            put_change(changeset, :totalprice, realquantity * price)
          _ ->
            changeset
        end
      end
  end
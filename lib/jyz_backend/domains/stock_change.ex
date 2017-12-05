defmodule JyzBackend.StockChange do
    use Ecto.Schema
    import Ecto.Changeset
    # alias JyzBackend.{User, ContractForPurchase, ContractForPurchaseDetail}
    
    schema "stock_change" do
      field :cno, :string          # 单号
      field :date, :string         # 计算时间
      field :model, :string        # 型号
      field :amount, :float        # 数量
      field :warehouse, :string    # 仓库
      field :type, string          # 出入库类型
      field :stockin, :boolean     # true：入库，false：出库
      field :calculated, :boolean  # true：已计算，false：未计算

      timestamps()
    end
      
    @doc false
    def changeset(%StockChange{} = stockchange, attrs) do
        stockchange
        |> cast(attrs, [:cno, :date, :model, :amount, :warehouse, :type, :stockin, :calculated])
        |> validate_required([:cno, :model, :amount, :warehouse, :type, :stockin, :calculated])
        |> validate_length(:cno, min: 4)
    end
 
end
defmodule JyzBackend.StockChange do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.StockChange
    # alias JyzBackend.{User, ContractForPurchase, ContractForPurchaseDetail}
    
    schema "stock_change" do
      field :cno, :string          # 单号
      field :date, :string         # 计算时间
      field :model, :string        # 型号
      field :amount, :float        # 数量
      field :warehouse, :string    # 仓库
      field :type, :string          # 出入库类型
      field :calculated, :boolean  # true：已计算，false：未计算
      field :cal_status, :boolean      # 计算状态，true：成功，false：失败

      timestamps()
    end
      
    @doc false
    def changeset(%StockChange{} = stockchange, attrs) do
        stockchange
        |> cast(attrs, [:cno, :date, :model, :amount, :warehouse, :type, :calculated, :cal_status])
        |> validate_required([:cno, :model, :amount, :warehouse, :type, :calculated])
        |> validate_length(:cno, min: 4)
    end
 
end
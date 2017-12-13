defmodule JyzBackend.OilDepot do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{OilDepot}
    
    schema "oil_depot" do
      field :depotname, :string     #仓库名称
      field :oilname, :string       #油品名称
      field :depotiddr, :string     #仓库地址
      field :kind, :string          #油品类型  
      field :number, :float         #数量             
      timestamps()
    end
      
    @doc false
    def changeset(%OilDepot{} = oildepot, attrs) do
        oildepot
        |> cast(attrs, [:depotname, :oilname, :depotiddr, :kind, :number])#前台传数据
        |> validate_required([:depotname, :oilname, :depotiddr, :kind, :number])#前台必填字段
       # |> unique_constraint(:billno)
       # |> validate_length(:billno, min: 4)
    end
  
    # 自定义验证器
    defp validate_positive_number(changeset, field, options \\ []) do
      validate_change(changeset, field, fn _, n ->
        case n > 0 do
          true -> []
          false -> [{field, options[:message] || "无效号码"}]
        end
      end)
    end
  
  end
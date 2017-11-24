defmodule JyzBackend.OilTransfer do
    use Ecto.Schema
    import Ecto.Changeset
    alias JyzBackend.{OilTransfer, OilTransferDetail}
    
    schema "oil_transfer" do
      field :billno, :string     #调拨单号
      field :date, :string       #日期
      field :stockplace, :string #移出罐（车）号
      field :dispatcher, :string #调度
      field :stockman, :string   #保管员
      field :checker, :string    #核算员 
      field :create_user, :string              #录入人
      field :audit_user, :string               #审核人
      field :audited, :boolean, default: false #审核状态
      field :audit_time, :string               #审核时间
      has_many :oil_transfer_details, OilTransferDetail, on_delete: :delete_all, on_replace: :delete
      timestamps()
    end
      
    @doc false
    def changeset(%OilTransfer{} = oilTransfer, attrs) do
        oilTransfer
        |> cast(attrs, [:billno, :date, :stockplace, :dispatcher, :stockman,
         :checker, :create_user, :audit_user, :audited, :audit_time])#前台传数据
        |> validate_required([:billno, :dispatcher, :date, :stockman, :checker])#前台必填字段
        |> unique_constraint(:billno)
        |> validate_length(:billno, min: 4)
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
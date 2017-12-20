defmodule JyzBackend.Repo.Migrations.CreateTableCarryForAccountAndDetails do
  use Ecto.Migration

  def change do
    create table("carry_for_account") do
      add :companyname, :string , null: false #公司名称
     add :date, :string                      #日期
     add :responsibleperson, :string         #负责人
     add :operator, :string                  #经办人
     add :audited, :boolean, default: false
     add :audit_time, :string
     add :audit_user, :string
     add :create_user, :string
 
       timestamps()
     end
     
     create table("carry_for_account_details") do
       add :stockcompany, :string  , null: false #存货单位
       add :variety, :string                   #品种 
       add :lastt, :float  , default: 0        #上期结存（吨）
       add :lastl, :float  , default: 0         #上期结存（升）
       add :stockt, :float  , default: 0        #本月存油（吨）
       add :stockl, :float   , default: 0       #本月存油（升）
       add :monthpickupt, :float  , default: 0  #本月提用（吨）
       add :monthpickupl, :float  , default: 0  #本月提用（升）
       add :monthstockt, :float  , default: 0   #本月结存（吨）
       add :monthstockl, :float   , default: 0  #本月结存（升）
       add :carry_for_account_id, references(:carry_for_account)
     
       timestamps()
     end
  end
end

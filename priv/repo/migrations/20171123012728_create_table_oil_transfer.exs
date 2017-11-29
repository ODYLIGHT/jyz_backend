defmodule JyzBackend.Repo.Migrations.CreateTableOilTransfer do
  use Ecto.Migration

  def change do
    create table("oil_transfer") do
      add :billno, :string, null: false
      add :date, :string       #日期
      add :stockplace, :string, default: 20170000 #移出罐（车）号
      add :dispatcher, :string #调度
      add :stockman, :string   #保管员
      add :checker, :string    #核算员 
      add :entryer, :string    #录入人
      add :auditer, :string    #审核人
      add :state, :string      #状态
      add :auditdate, :string  #审核时间

      timestamps()
    end
  end
end

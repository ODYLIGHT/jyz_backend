defmodule JyzBackend.Repo.Migrations.CreateTableOilTransferAndDetails do
  use Ecto.Migration

  def change do
    create table("oil_transfer") do
      
        add :billno, :string, null: false
        add :date, :string       #日期        
        add :stockplace, :string, default: 20170000 #移出罐（车）号      
        add :dispatcher, :string #调度 
        add :stockman, :string   #保管员
        add :checker, :string    #核算员 
        add :create_user, :string                           #录入人  
        add :audit_user, :string                            #审核人
        add :audited, :boolean, null: false, default: false #审核状态
        add :audit_time, :string                            #审核时间
       timestamps()
      end
       
     create table("oil_transfer_details") do
         add :billno1, :string, null: false
         add :stockpalce, :string
         add :Unit, :string
         add :Startdegree, :float, default: 0
         add :Enddegree, :float, default: 0
         add :quantity, :float, default: 0
         add :Confirmation, :string
         add :oil_transfer_id, references(:oil_transfer)
        timestamps()    
     end
  end
end

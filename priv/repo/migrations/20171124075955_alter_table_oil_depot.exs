defmodule JyzBackend.Repo.Migrations.AlterTableOilDepot do
  use Ecto.Migration

  def change do
    alter table("oil_depot") do
      remove :DepotName    
      remove :OilName     
      remove :DepotIDDR  
      remove :Kind  
      add :depotname, :string     #仓库名称
      add :oilname, :string       #油品名称
      add :depotiddr, :string     #仓库地址
      add :kind, :string          #油品类型  
    end

  end
end

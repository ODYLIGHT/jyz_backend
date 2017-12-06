defmodule JyzBackend.Repo.Migrations.CreateTableOilDepot do
  use Ecto.Migration

  def change do
    create table("oil_depot") do
      add :DepotName, :string     #仓库名称
      add :OilName, :string       #油品名称
      add :DepotIDDR, :string     #仓库地址
      add :Kind, :string          #油品类型   
                  
      timestamps()
    end
  end
end

defmodule JyzBackend.Repo.Migrations.CreateTableOilDepot do
  use Ecto.Migration

  def change do
    create table("oil_depot") do
      add :depotname, :string     #仓库名称
      add :oilname, :string       #油品名称
      add :depotiddr, :string     #仓库地址
      add :kind, :string          #油品类型
      add :number, :float         #数量
      
      timestamps()
    end
  end
end

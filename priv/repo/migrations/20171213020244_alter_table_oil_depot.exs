defmodule JyzBackend.Repo.Migrations.AlterTableOilDepot do
  use Ecto.Migration

  def change do
    alter table("oil_depot")do
      add :number, :float #数量
    end

  end
end

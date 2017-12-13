defmodule JyzBackend.Repo.Migrations.CreateTableStockChange do
  use Ecto.Migration

  def change do
    create table("stock_change") do
      add :cno, :string, null: false
      add :date, :string
      add :model, :string, null: false
      add :amount, :float, null: false, default: 0
      add :warehouse, :string, null: false
      add :type, :string, null: false
      add :calculated, :boolean, null: false, default: false
      add :cal_status, :boolean
      timestamps()
    end
  end
end

defmodule JyzBackend.Repo.Migrations.CreateTableOilTransferDetail do
  use Ecto.Migration

  def change do
    create table("oil_transfer_details") do
      add :Billno, :string, null: false
      add :Stockpalce, :string
      add :Unit, :string
      add :Startdegree, :float, default: 0
      add :Enddegree, :float, default: 0
      add :Quantity, :float, default: 0
      add :Confirmation, :string
      add :oil_transfer_id, references(:oil_transfer)
      
      timestamps()
    end

  end
end

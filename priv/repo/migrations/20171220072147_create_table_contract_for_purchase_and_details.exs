defmodule JyzBackend.Repo.Migrations.CreateTableContractForPurchaseAndDetails do
  use Ecto.Migration

  def change do
    create table("contract_for_purchase") do
      add :cno, :string, null: false
      add :date, :string
      add :location, :string
      add :amount, :float, default: 0
      add :partya, :string
      add :partyb, :string
      add :audited, :boolean, null: false, default: false
      add :create_user, :string
      add :audit_time, :string
      add :audit_user, :string
      timestamps()
    end
    
    create table("contract_for_purchase_details") do
      add :product, :string, null: false
      add :model, :string
      add :producer, :string
      add :amount, :float, default: 0
      add :unit, :string
      add :price, :float, default: 0
      add :totalprice, :float, default: 0
      add :contract_for_purchase_id, references(:contract_for_purchase)
    
      timestamps()
    end
  end
end

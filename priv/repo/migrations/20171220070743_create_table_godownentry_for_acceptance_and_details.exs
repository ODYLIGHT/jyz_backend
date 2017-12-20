defmodule JyzBackend.Repo.Migrations.CreateTableGodownentryForAcceptanceAndDetails do
  use Ecto.Migration

  def change do
    create table("godownentry_for_acceptance") do
      add :bno, :string, null: false
      add :supplier, :string
      add :cno, :string
      add :buyer, :string
      add :examiner, :string
      add :accountingstaff, :string
      add :create_user, :string
      add :audit_user, :string
      add :audited, :boolean, null: false, default: false
      add :audit_time, :string

      timestamps()
    end
    
    create table("godownentry_for_acceptance_details") do
      add :oilname, :string, null: false
      add :planquantity, :float, default: 0
      add :realquantity, :float, default: 0
      add :price, :float, default: 0
      add :totalprice, :float, default: 0
      add :stockplace, :string
      add :comment, :string
      add :godownentry_for_acceptance_id, references(:godownentry_for_acceptance)
    
      timestamps()
    end
  end
end

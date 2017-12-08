defmodule JyzBackend.Repo.Migrations.CreateTableGodownentryForAcceptanceAndDetail do
  use Ecto.Migration

  def change do
 create table("Godownentry_for_acceptance") do
      add :bno, :string, null: false
      add :supplier, :string
      add :cno, :string
      add :buyer, :string
      add :examiner, :string
      add :accountingstaff, :string
      add :entryperson, :string
      add :auditPerson, :string
      add :state, :string
      add :auditdate, :string

      timestamps()
    end
    
    create table("Godownentry_for_acceptance_details") do
      add :oilname, :string, null: false
      add :planquantity, :float, default: 0
      add :realquantity, :float, default: 0
      add :price, :float, default: 0
      add :totalprice, :float, default: 0
      add :stockplace, :integer
      add :comment, :string
      add :Godownentry_for_acceptance_id, references(:Godownentry_for_acceptance)
    
      timestamps()
    end

  end
end

defmodule JyzBackend.Repo.Migrations.AlterTableContractForPurchaseAddAudited do
  use Ecto.Migration

  def change do
    alter table("contract_for_purchase") do
      add :audited, :boolean, null: false, default: false
    end
  end
end

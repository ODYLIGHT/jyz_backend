defmodule JyzBackend.Repo.Migrations.AlterTableContractForPurchaseAuditColumns do
  use Ecto.Migration

  def change do
    alter table("contract_for_purchase") do
      remove :creater
      add :create_user, :string
      add :audit_user, :string
    end
  end
end

defmodule JyzBackend.Repo.Migrations.AlterTableContractForPurchaseAddColumnAudittimeAndCreater do
  use Ecto.Migration

  def change do
    alter table("contract_for_purchase") do
      add :creater, :integer
      add :audit_time, :string
    end
  end
end

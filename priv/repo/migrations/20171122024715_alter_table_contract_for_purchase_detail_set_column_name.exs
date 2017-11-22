defmodule JyzBackend.Repo.Migrations.AlterTableContractForPurchaseDetailSetColumnName do
  use Ecto.Migration

  def change do
    rename table("contract_for_purchase_details"), :cfp_id, to: :contract_for_purchase_id
  end
end

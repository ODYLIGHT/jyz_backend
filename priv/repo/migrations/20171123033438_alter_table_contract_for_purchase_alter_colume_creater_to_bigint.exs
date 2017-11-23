defmodule JyzBackend.Repo.Migrations.AlterTableContractForPurchaseAlterColumeCreaterToBigint do
  use Ecto.Migration

  def change do
    alter table("contract_for_purchase") do
      modify :creater, :bigint
    end
  end
end

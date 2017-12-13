defmodule JyzBackend.Repo.Migrations.AlterTableGodownentryColumnStockplaceToString do
  use Ecto.Migration

  def change do
    alter table("godownentry_for_acceptance_details") do
      modify :stockplace, :string
    end
  end
end

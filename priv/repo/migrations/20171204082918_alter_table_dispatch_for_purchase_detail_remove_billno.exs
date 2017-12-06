defmodule JyzBackend.Repo.Migrations.AlterTableDispatchForPurchaseDetailRemoveBillno do
  use Ecto.Migration

  def change do
    alter table("dispatch_for_purchase_details")do
      remove :billno
     end
  end
end

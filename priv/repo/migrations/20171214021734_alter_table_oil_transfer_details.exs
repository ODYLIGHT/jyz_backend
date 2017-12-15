defmodule JyzBackend.Repo.Migrations.AlterTableOilTransferDetails do
  use Ecto.Migration

  def change do
    rename table("oil_transfer_details"), :Billno, to: :billno1
  end
end

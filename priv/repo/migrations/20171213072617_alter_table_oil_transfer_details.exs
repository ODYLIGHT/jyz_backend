defmodule JyzBackend.Repo.Migrations.AlterTableOilTransferDetails do
  use Ecto.Migration

  def change do
      rename table("oil_transfer_details"), :Stockpalce, to: :stockpalce
      rename table("oil_transfer_details"), :Quantity, to: :quantity   
  end
end

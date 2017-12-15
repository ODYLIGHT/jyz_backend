defmodule JyzBackend.Repo.Migrations.AlterTableMeteringColumnStockpalceToString do
  use Ecto.Migration

  def change do
  	alter table("metering_for_return_details") do
      modify :stockplace, :string
    end
  end
end




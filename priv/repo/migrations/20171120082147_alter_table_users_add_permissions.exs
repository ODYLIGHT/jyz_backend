defmodule JyzBackend.Repo.Migrations.AlterTableUsersAddPermissions do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :permissions, :integer
    end
  end
end

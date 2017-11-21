defmodule JyzBackend.Repo.Migrations.AlterTableUsersAddActive do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :active, :Boolean
    end
  end
end

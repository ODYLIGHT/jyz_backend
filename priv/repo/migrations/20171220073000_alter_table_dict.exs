defmodule JyzBackend.Repo.Migrations.AlterTableDict do
  use Ecto.Migration

  def change do
    alter table("dict") do
      remove :value
      remove :seq
    end
  end
end

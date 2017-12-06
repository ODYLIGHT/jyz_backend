defmodule JyzBackend.Repo.Migrations.CreateTableDictForUse do
  use Ecto.Migration

  def change do
 create table("dict_for_use") do
      add :code, :string, null: false
      add :name, :string
      add :key, :string
      add :parm, :string
      add :value, :float
      add :seq, :integer

      timestamps()
    end
  end
end

defmodule JyzBackend.Repo.Migrations.CreateTableDict do
  use Ecto.Migration

  def change do
  drop table ("dict_for_use")

create table("dict") do
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

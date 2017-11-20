defmodule JyzBackend.Repo.Migrations.CreateTableUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :username, :string, null: false
      add :password_hash, :string, null: false
      add :email, :string, null: false
      add :fullname, :string, default: ""
      add :position, :string, default: ""
      add :is_admin, :boolean
      add :avatar, :string
    
      timestamps()
    end
  end
end

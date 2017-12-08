defmodule JyzBackend.Repo.Migrations.AlterTableGodownForAcceptance do
  use Ecto.Migration

  def change do
  rename table("godownentry_for_acceptance"), :auditdate, to: :audit_time
  rename table("godownentry_for_acceptance"), :entryperson, to: :create_user
  rename table("godownentry_for_acceptance"), :auditPerson, to: :audit_user
  alter table("godownentry_for_acceptance") do
      remove :state
      add :audited, :boolean, null: false, default: false
    end
  end
end


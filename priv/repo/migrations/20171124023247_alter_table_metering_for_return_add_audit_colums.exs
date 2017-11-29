defmodule JyzBackend.Repo.Migrations.AlterTableMeteringForReturnAddAuditColums do
  use Ecto.Migration

  def change do
    alter table("metering_for_return") do
      remove :entryperson
      remove :auditperson
      remove :state
      remove :auditdate
      add :audited, :boolean, default: false
      add :audit_time, :string
      add :audit_user, :string
      add :create_user, :string
  end
end
end

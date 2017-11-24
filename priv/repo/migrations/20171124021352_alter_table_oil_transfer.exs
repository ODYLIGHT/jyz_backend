defmodule JyzBackend.Repo.Migrations.AlterTableOilTransfer do
  use Ecto.Migration

  def change do
    alter table("oil_transfer")do
      remove :entryer
      remove :auditer
      remove :state
      remove :auditdate
      add :create_user, :string                           #录入人
      add :audit_user, :string                            #审核人
      add :audited, :boolean, null: false, default: false #审核状态
      add :audit_time, :string                            #审核时间
    end
  end
end

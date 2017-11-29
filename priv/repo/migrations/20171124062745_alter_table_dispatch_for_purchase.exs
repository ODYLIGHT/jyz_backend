defmodule JyzBackend.Repo.Migrations.AlterTableDispatchForPurchase do
  use Ecto.Migration

  def change do
   alter table("dispatch_for_purchase")do
      remove :entryperson
      remove :auditperson
      remove :state
      remove :auditdate
      add :create_user, :string                           
      add :audit_user, :string                            
      add :audited, :boolean, null: false, default: false 
      add :audit_time, :string                            
    end
  end
end

 

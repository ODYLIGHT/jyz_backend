defmodule JyzBackend.Repo.Migrations.CreateTableMeteringForReturnAndDetail do
  use Ecto.Migration

  def change do
  	create table("metering_for_return") do
  		add :billno, :string, null: false
  		add :billdate, :string
  		add :stockman, :string
    	add :accountingclerk, :string
    	add :entryperson, :string
    	add :auditperson, :string
    	add :state, :string
    	add :comment, :string
    	add :auditdate, :string 

    	timestamps()
  	end

  	create table ("metering_for_return_details") do
  		add :wagonno, :string
      	add :cardno, :string
      	add :oilname, :string
      	add :unit, :string
      	add :quantity, :float, default: 0
      	add :stockplace, :float, default: 0
      	add :comment, :string
      	add :metering_for_return_id, references(:metering_for_return)
    
        timestamps()
    end

  end
end



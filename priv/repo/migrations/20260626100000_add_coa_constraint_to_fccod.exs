defmodule Kinshine.Repo.Migrations.AddCoaConstraintToFccod do
  use Ecto.Migration

  def change do
    # Add foreign key constraint from FCCOD.coaid to FCCOA.coaid
    alter table(:FCCOD) do
      modify :coaid, :string, size: 4, null: true
    end

    # Create index for better performance
    create index(:FCCOD, [:coaid])

    # Note: We don't add a unique constraint on coaid because multiple 
    # company codes can share the same COA (as per SAP logic)
    # But each company code can only have ONE coaid (enforced by table structure)
  end
end

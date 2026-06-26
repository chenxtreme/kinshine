defmodule Kinshine.Repo.Migrations.CreateChartOfAccounts do
  use Ecto.Migration

  def change do
    # ============================================================
    # 1. Create FCCOA — Chart of Account Master (SAP: T004 / KTOPL)
    # ============================================================
    create table("FCCOA", primary_key: false) do
      add :coaid, :string, primary_key: true, size: 4
      add :coanam, :string, null: false, size: 100

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # ============================================================
    # 2. Create FCCGL — COA GL Account
    #    Replaces old CompanyCodeGLAccount concept
    # ============================================================
    create table("FCCGL", primary_key: false) do
      add :coaid, references("FCCOA", column: :coaid, type: :string), null: false
      add :acnum, references("FCGLM", column: :acnum, type: :string), null: false

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    create index("FCCGL", [:coaid])
    create index("FCCGL", [:acnum])
    create unique_index("FCCGL", [:coaid, :acnum], name: :fccgl_coaid_acnum_index)
  end
end

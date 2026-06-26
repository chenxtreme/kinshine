defmodule Kinshine.Repo.Migrations.CreateFinanceTables do
  use Ecto.Migration

  def change do
    # ============================================================
    # FASE 0: ORGANIZATIONAL STRUCTURE
    # ============================================================

    # FCCOD - Company Code (SAP: T001)
    create table(:FCCOD, primary_key: false) do
      add :comcod, :string, primary_key: true, size: 4
      add :comnam, :string, size: 100
      add :comadd, :string, size: 255
      add :comcty, :string, size: 50
      # Currency (SAP: WAERS)
      add :comcrn, :string, size: 3
      # Chart of Account (FK to FCCOA)
      add :coaid, :string, size: 4

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # FFYVR - Fiscal Year Variant (SAP: T009)
    create table(:FFYVR, primary_key: false) do
      add :fyyid, :string, primary_key: true, size: 2
      add :fyynam, :string, size: 50
      # Starting month (1=Jan, 4=Apr, etc)
      add :fystrt, :integer

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # FPPVR - Posting Period Variant (SAP: T004V)
    create table(:FPPVR, primary_key: false) do
      add :ppvid, :string, primary_key: true, size: 4
      add :ppvnam, :string, size: 50
      # Number of periods
      add :numper, :integer, default: 12
      # Number of special periods
      add :numspe, :integer, default: 4

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # FPPCN - Posting Period Control (SAP: T001B)
    create table(:FPPCN, primary_key: false) do
      add :ppcid, :binary_id, primary_key: true
      add :comcod, references(:FCCOD, column: :comcod, type: :string), null: false
      add :ppvid, references(:FPPVR, column: :ppvid, type: :string), null: false
      add :fyear, :integer, null: false
      # Period number
      add :perid, :integer, null: false
      # Status: X=Open, C=Close
      add :persta, :string, size: 1, default: "X"
      # Open date
      add :peropn, :date
      # Close date
      add :percls, :date

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    create index(:FPPCN, [:comcod])
    create index(:FPPCN, [:ppvid])
    create unique_index(:FPPCN, [:comcod, :fyear, :perid])

    # ============================================================
    # FASE 1: CHART OF ACCOUNTS (COA)
    # ============================================================

    # FCAGR - Account Group (SAP: KONTOGRUPPE)
    create table(:FCAGR, primary_key: false) do
      add :acgid, :string, primary_key: true, size: 4
      add :acgnam, :string, size: 50
      # A=Asset, L=Liability, E=Equity, R=Revenue, C=Cost
      add :acgtyp, :string, size: 1

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # FCGLM - GL Account Master (SAP: SKA1)
    create table(:FCGLM, primary_key: false) do
      add :acnum, :string, primary_key: true, size: 10
      add :acnam, :string, size: 100
      add :acgid, references(:FCAGR, column: :acgid, type: :string), null: false
      add :acdesc, :string, size: 255

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    create index(:FCGLM, [:acgid])

    # FCCGL - COA GL Account (will be created in CreateChartOfAccounts migration)
    # Skipped here to avoid conflicts with the new COA-based FCCGL structure
  end
end

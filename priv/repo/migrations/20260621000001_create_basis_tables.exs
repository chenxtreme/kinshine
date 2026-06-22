defmodule Kinshine.Repo.Migrations.CreateBasisTables do
  use Ecto.Migration

  def change do
    # BPROF - Master Profile / Role
    create table("BPROF", primary_key: false) do
      add :profid, :binary_id, primary_key: true
      add :pronam, :string, null: false
      add :prodes, :string

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # BPAGE - Master Page (Link Target)
    create table("BPAGE", primary_key: false) do
      add :pageid, :binary_id, primary_key: true
      add :pagtit, :string, null: false
      add :pagurl, :string, null: false

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    # BMENU - ERP Menu Tree (self-referencing)
    create table("BMENU", primary_key: false) do
      add :menuid, :binary_id, primary_key: true

      add :menpar,
          references("BMENU", column: :menuid, type: :binary_id, on_delete: :nilify_all)

      add :pageid,
          references("BPAGE", column: :pageid, type: :binary_id, on_delete: :nilify_all)

      add :mennam, :string, null: false
      add :mensrt, :integer, null: false, default: 0

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    create index("BMENU", [:menpar])
    create index("BMENU", [:pageid])

    # BUSPR - Pivot: User <-> Profile
    create table("BUSPR", primary_key: false) do
      add :userid,
          references("BUSER", column: :userid, type: :binary_id, on_delete: :delete_all),
          null: false

      add :profid,
          references("BPROF", column: :profid, type: :binary_id, on_delete: :delete_all),
          null: false
    end

    create unique_index("BUSPR", [:userid, :profid])

    # BPRPG - Pivot: Profile <-> Page
    create table("BPRPG", primary_key: false) do
      add :profid,
          references("BPROF", column: :profid, type: :binary_id, on_delete: :delete_all),
          null: false

      add :pageid,
          references("BPAGE", column: :pageid, type: :binary_id, on_delete: :delete_all),
          null: false
    end

    create unique_index("BPRPG", [:profid, :pageid])
  end
end

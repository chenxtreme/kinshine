defmodule Kinshine.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table("BUSER", primary_key: false) do
      add :userid, :binary_id, primary_key: true
      add :emails, :citext, null: false
      add :passwd, :string
      add :confirmed_at, :utc_datetime

      timestamps(inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime)
    end

    create unique_index("BUSER", [:emails])

    create table(:users_tokens) do
      add :userid, references("BUSER", column: :userid, type: :binary_id, on_delete: :delete_all),
        null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:userid])
    create unique_index(:users_tokens, [:context, :token])
  end
end

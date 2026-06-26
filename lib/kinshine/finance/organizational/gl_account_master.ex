defmodule Kinshine.Finance.Organizational.GLAccountMaster do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:acnum, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FCGLM" do
    field :acnam, :string
    field :acgid, :string
    field :acdesc, :string

    timestamps()
  end

  def changeset(gl_account_master, attrs) do
    gl_account_master
    |> cast(attrs, [:acnum, :acnam, :acgid, :acdesc])
    |> validate_required([:acnum, :acnam, :acgid])
    |> validate_length(:acnum, max: 10)
    |> validate_length(:acnam, max: 100)
    |> validate_length(:acdesc, max: 255)
    |> unique_constraint(:acnum)
  end
end

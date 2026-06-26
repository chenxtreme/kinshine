defmodule Kinshine.Finance.Organizational.AccountGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:acgid, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FCAGR" do
    field :acgnam, :string
    # A=Asset, L=Liability, E=Equity, R=Revenue, C=Cost
    field :acgtyp, :string

    timestamps()
  end

  def changeset(account_group, attrs) do
    account_group
    |> cast(attrs, [:acgid, :acgnam, :acgtyp])
    |> validate_required([:acgid, :acgnam, :acgtyp])
    |> validate_length(:acgid, max: 4)
    |> validate_length(:acgnam, max: 50)
    |> validate_inclusion(:acgtyp, ["A", "L", "E", "R", "C"],
      message: "must be A (Asset), L (Liability), E (Equity), R (Revenue), or C (Cost)"
    )
    |> unique_constraint(:acgid)
  end
end

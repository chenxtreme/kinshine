defmodule Kinshine.Finance.Organizational.FiscalYearVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:fyyid, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FFYVR" do
    field :fyynam, :string
    field :fystrt, :integer

    timestamps()
  end

  def changeset(fiscal_year_variant, attrs) do
    fiscal_year_variant
    |> cast(attrs, [:fyyid, :fyynam, :fystrt])
    |> validate_required([:fyyid, :fyynam, :fystrt])
    |> validate_length(:fyyid, max: 2)
    |> validate_length(:fyynam, max: 50)
    |> validate_inclusion(:fystrt, 1..12, message: "must be between 1 (Jan) and 12 (Dec)")
    |> unique_constraint(:fyyid)
  end
end

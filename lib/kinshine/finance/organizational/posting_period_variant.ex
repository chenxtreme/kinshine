defmodule Kinshine.Finance.Organizational.PostingPeriodVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:ppvid, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FPPVR" do
    field :ppvnam, :string
    field :numper, :integer, default: 12
    field :numspe, :integer, default: 4

    timestamps()
  end

  def changeset(posting_period_variant, attrs) do
    posting_period_variant
    |> cast(attrs, [:ppvid, :ppvnam, :numper, :numspe])
    |> validate_required([:ppvid, :ppvnam])
    |> validate_length(:ppvid, max: 4)
    |> validate_length(:ppvnam, max: 50)
    |> validate_number(:numper, greater_than: 0, less_than: 367)
    |> validate_number(:numspe, greater_than_or_equal_to: 0, less_than: 100)
    |> unique_constraint(:ppvid)
  end
end

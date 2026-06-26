defmodule Kinshine.Finance.Organizational.PostingPeriodControl do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:ppcid, :binary_id, autogenerate: true}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FPPCN" do
    field :comcod, :string
    field :ppvid, :string
    field :fyear, :integer
    field :perid, :integer
    # X=Open, C=Close
    field :persta, :string, default: "X"
    field :peropn, :date
    field :percls, :date

    timestamps()
  end

  def changeset(posting_period_control, attrs) do
    posting_period_control
    |> cast(attrs, [:comcod, :ppvid, :fyear, :perid, :persta, :peropn, :percls])
    |> validate_required([:comcod, :ppvid, :fyear, :perid])
    |> validate_inclusion(:persta, ["X", "C"])
    |> validate_number(:fyear, greater_than: 1900, less_than: 2200)
    |> validate_number(:perid, greater_than: 0, less_than: 368)
    |> unique_constraint([:comcod, :fyear, :perid], name: :fppcn_comcod_fyear_perid_index)
  end
end

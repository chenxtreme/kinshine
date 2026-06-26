defmodule Kinshine.Finance.Organizational.ChartOfAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:coaid, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FCCOA" do
    field :coanam, :string

    timestamps()
  end

  def changeset(chart_of_account, attrs) do
    chart_of_account
    |> cast(attrs, [:coaid, :coanam])
    |> validate_required([:coaid, :coanam])
    |> validate_length(:coaid, max: 4)
    |> validate_length(:coanam, max: 100)
    |> validate_format(:coaid, ~r/^[A-Z0-9]+$/, message: "must be uppercase alphanumeric")
    |> unique_constraint(:coaid)
  end
end

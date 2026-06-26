defmodule Kinshine.Finance.Organizational.CompanyCode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:comcod, :string, []}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "FCCOD" do
    field :comnam, :string
    field :comadd, :string
    field :comcty, :string
    field :comcrn, :string

    belongs_to :chart_of_account, Kinshine.Finance.Organizational.ChartOfAccount,
      type: :string,
      foreign_key: :coaid,
      references: :coaid

    timestamps()
  end

  def changeset(company_code, attrs) do
    company_code
    |> cast(attrs, [:comcod, :comnam, :comadd, :comcty, :comcrn, :coaid])
    |> validate_required([:comcod, :comnam, :comcrn])
    |> validate_length(:comcod, max: 4)
    |> validate_length(:comnam, max: 100)
    |> validate_length(:comadd, max: 255)
    |> validate_length(:comcty, max: 50)
    |> validate_length(:comcrn, max: 3)
    |> validate_length(:coaid, max: 4)
    |> validate_format(:comcod, ~r/^[A-Z0-9]+$/, message: "must be uppercase alphanumeric")
    |> validate_format(:coaid, ~r/^[A-Z0-9]+$/,
      message: "must be uppercase alphanumeric",
      allow_nil: true
    )
    |> unique_constraint(:comcod)
    |> foreign_key_constraint(:coaid)
  end
end

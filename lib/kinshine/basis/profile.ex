defmodule Kinshine.Basis.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:profid, :binary_id, autogenerate: true}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "BPROF" do
    field :pronam, :string
    field :prodes, :string

    timestamps()
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:pronam, :prodes])
    |> validate_required([:pronam])
    |> validate_length(:pronam, max: 255)
  end
end

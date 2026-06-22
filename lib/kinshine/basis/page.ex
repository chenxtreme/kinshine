defmodule Kinshine.Basis.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:pageid, :binary_id, autogenerate: true}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "BPAGE" do
    field :pagtit, :string
    field :pagurl, :string

    timestamps()
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:pagtit, :pagurl])
    |> validate_required([:pagtit, :pagurl])
    |> validate_length(:pagtit, max: 255)
    |> validate_length(:pagurl, max: 255)
  end
end

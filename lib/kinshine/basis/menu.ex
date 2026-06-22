defmodule Kinshine.Basis.Menu do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kinshine.Basis.{Menu, Page}

  @primary_key {:menuid, :binary_id, autogenerate: true}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "BMENU" do
    field :mennam, :string
    field :mensrt, :integer, default: 0

    belongs_to :parent, Menu, foreign_key: :menpar, references: :menuid, type: :binary_id
    belongs_to :page, Page, foreign_key: :pageid, references: :pageid, type: :binary_id

    timestamps()
  end

  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:mennam, :mensrt, :menpar, :pageid])
    |> validate_required([:mennam])
    |> validate_length(:mennam, max: 255)
  end
end

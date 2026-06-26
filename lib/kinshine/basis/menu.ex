defmodule Kinshine.Basis.Menu do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Kinshine.Basis.{Menu, Page}
  alias Kinshine.Repo

  @primary_key {:menuid, :binary_id, autogenerate: true}
  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  schema "BMENU" do
    field :mennam, :string
    field :mensrt, :integer, default: 0
    field :mnlink, :string

    belongs_to :parent, Menu, foreign_key: :menpar, references: :menuid, type: :binary_id
    belongs_to :page, Page, foreign_key: :pageid, references: :pageid, type: :binary_id

    timestamps()
  end

  def changeset(menu, attrs) do
    menu
    |> cast(attrs, [:mennam, :mensrt, :menpar, :pageid, :mnlink])
    |> validate_required([:mennam])
    |> validate_length(:mennam, max: 255)
    |> validate_length(:mnlink, max: 500)
    |> validate_unique_mennam()
  end

  defp validate_unique_mennam(changeset) do
    mennam = get_field(changeset, :mennam)

    if mennam do
      menuid = get_field(changeset, :menuid)

      query =
        if menuid do
          from m in Menu,
            where:
              fragment("LOWER(?)", m.mennam) == fragment("LOWER(?)", ^mennam) and
                m.menuid != ^menuid
        else
          from m in Menu,
            where: fragment("LOWER(?)", m.mennam) == fragment("LOWER(?)", ^mennam)
        end

      if Repo.exists?(query) do
        add_error(changeset, :mennam, "has already been taken")
      else
        changeset
      end
    else
      changeset
    end
  end
end

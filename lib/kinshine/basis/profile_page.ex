defmodule Kinshine.Basis.ProfilePage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kinshine.Basis.{Profile, Page}

  @primary_key false

  schema "BPRPG" do
    belongs_to :profile, Profile, foreign_key: :profid, references: :profid, type: :binary_id
    belongs_to :page, Page, foreign_key: :pageid, references: :pageid, type: :binary_id
  end

  def changeset(profile_page, attrs) do
    profile_page
    |> cast(attrs, [:profid, :pageid])
    |> validate_required([:profid, :pageid])
    |> unique_constraint([:profid, :pageid])
  end
end

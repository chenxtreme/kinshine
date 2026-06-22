defmodule Kinshine.Basis.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kinshine.Accounts.User
  alias Kinshine.Basis.Profile

  @primary_key false

  schema "BUSPR" do
    belongs_to :user, User, foreign_key: :userid, references: :userid, type: :binary_id
    belongs_to :profile, Profile, foreign_key: :profid, references: :profid, type: :binary_id
  end

  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:userid, :profid])
    |> validate_required([:userid, :profid])
    |> unique_constraint([:userid, :profid])
  end
end

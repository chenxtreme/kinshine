defmodule Kinshine.Finance.Organizational.CoaGLAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [inserted_at: :insdat, updated_at: :upddat, type: :utc_datetime]

  @primary_key false
  schema "FCCGL" do
    field :coaid, :string
    field :acnum, :string

    timestamps()
  end

  def primary_key, do: [:coaid, :acnum]

  def changeset(coa_gl_account, attrs) do
    coa_gl_account
    |> cast(attrs, [:coaid, :acnum])
    |> validate_required([:coaid, :acnum])
    |> unique_constraint([:coaid, :acnum], name: :fccgl_coaid_acnum_index)
  end
end

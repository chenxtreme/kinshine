defmodule Kinshine.Repo.Migrations.AddMnlinkToBmenu do
  use Ecto.Migration

  def change do
    alter table("BMENU") do
      add :mnlink, :string
    end
  end
end

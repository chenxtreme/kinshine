defmodule Kinshine.Repo do
  use Ecto.Repo,
    otp_app: :kinshine,
    adapter: Ecto.Adapters.Postgres
end

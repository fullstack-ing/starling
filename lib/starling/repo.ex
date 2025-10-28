defmodule Starling.Repo do
  use Ecto.Repo,
    otp_app: :starling,
    adapter: Ecto.Adapters.Postgres
end

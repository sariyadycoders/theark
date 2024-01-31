defmodule TheArk.Repo do
  use Ecto.Repo,
    otp_app: :the_ark,
    adapter: Ecto.Adapters.Postgres
end

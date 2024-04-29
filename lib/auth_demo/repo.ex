defmodule AuthDemo.Repo do
  use Ecto.Repo,
    otp_app: :auth_demo,
    adapter: Ecto.Adapters.Postgres
end

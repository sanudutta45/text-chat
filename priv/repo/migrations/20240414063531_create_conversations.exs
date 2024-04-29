defmodule AuthDemo.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :members, {:array, :string}
      add :last_message, :string

      timestamps(type: :utc_datetime)
    end
  end
end

defmodule AuthDemo.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :conversation_id, references(:conversations, type: :uuid, on_delete: :delete_all)
      add :sender_id, references(:users, type: :uuid)
      add :receiver_id, references(:users, type: :uuid)
      add :status, :integer
      add :text, :string

      timestamps(type: :utc_datetime)
    end
  end
end

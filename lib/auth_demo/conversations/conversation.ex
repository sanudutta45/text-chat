defmodule AuthDemo.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "conversations" do
    field :last_message, :string
    field :members, {:array, :string}
    has_many :messages, AuthDemo.Messages.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:members, :last_message])
    |> validate_required([:members])
  end
end

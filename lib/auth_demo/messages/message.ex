defmodule AuthDemo.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :status, :integer
    field :text, :string
    belongs_to :sender, AuthDemo.Account.User
    belongs_to :receiver, AuthDemo.Account.User
    belongs_to :conversation, AuthDemo.Conversations.Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:status, :text, :sender_id, :receiver_id, :conversation_id])
    |> validate_required([:text])
  end
end

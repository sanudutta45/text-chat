defmodule AuthDemo.Conversations do
  @moduledoc """
  The Conversations context.
  """

  import Ecto.Query, warn: false
  alias AuthDemo.Account
  alias AuthDemo.Repo

  alias AuthDemo.Conversations.Conversation

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations()
      [%Conversation{}, ...]

  """
  def list_conversations do
    Repo.all(Conversation)
  end

  def get_user_converstions(user_id) do
    query =
      from c in Conversation,
        left_join: m in assoc(c, :messages),
        on: c.id == m.conversation_id and m.status < 2 and m.receiver_id == ^user_id,
        where: ^user_id in c.members,
        order_by: [desc: c.updated_at],
        group_by: c.id,
        select: %{
          id: c.id,
          last_message: c.last_message,
          members: c.members,
          inserted_at: c.inserted_at,
          updated_at: c.updated_at,
          unread_messages: coalesce(count(m.id), 0)
        }

    query
    |> Repo.all()
    |> Enum.map(fn conversation ->
      external_member_id =
        conversation.members
        |> Enum.find(&(&1 != user_id))

      external_user = Account.get_user!(external_member_id)

      updated_conversation =
        Map.put(conversation, :chat_title, external_user.email)
        |> Map.put(:receiver_id, external_user.id)
        |> Map.put(:sender_id, user_id)

      updated_conversation
    end)
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(id), do: Repo.get!(Conversation, id)

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(attrs) do
    conversation = Repo.get!(Conversation, attrs.id)

    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(%Conversation{} = conversation) do
    Repo.delete(conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end
end

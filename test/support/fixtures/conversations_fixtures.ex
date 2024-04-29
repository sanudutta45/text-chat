defmodule AuthDemo.ConversationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AuthDemo.Conversations` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{

      })
      |> AuthDemo.Conversations.create_conversation()

    conversation
  end
end

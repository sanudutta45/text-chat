defmodule AuthDemo.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AuthDemo.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        conversation_id: "some conversation_id",
        receiver_id: "some receiver_id",
        sender_id: "some sender_id",
        status: 42
      })
      |> AuthDemo.Messages.create_message()

    message
  end
end

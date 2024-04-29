defmodule AuthDemo.MessagesTest do
  use AuthDemo.DataCase

  alias AuthDemo.Messages

  describe "messages" do
    alias AuthDemo.Messages.Message

    import AuthDemo.MessagesFixtures

    @invalid_attrs %{status: nil, conversation_id: nil, sender_id: nil, receiver_id: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messages.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messages.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{status: 42, conversation_id: "some conversation_id", sender_id: "some sender_id", receiver_id: "some receiver_id"}

      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)
      assert message.status == 42
      assert message.conversation_id == "some conversation_id"
      assert message.sender_id == "some sender_id"
      assert message.receiver_id == "some receiver_id"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{status: 43, conversation_id: "some updated conversation_id", sender_id: "some updated sender_id", receiver_id: "some updated receiver_id"}

      assert {:ok, %Message{} = message} = Messages.update_message(message, update_attrs)
      assert message.status == 43
      assert message.conversation_id == "some updated conversation_id"
      assert message.sender_id == "some updated sender_id"
      assert message.receiver_id == "some updated receiver_id"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, @invalid_attrs)
      assert message == Messages.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messages.change_message(message)
    end
  end
end

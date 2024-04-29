defmodule AuthDemoWeb.ChatLive do
  alias AuthDemoWeb.Endpoint
  alias AuthDemo.Messages.Message
  alias AuthDemo.Messages
  alias AuthDemo.Conversations
  alias AuthDemo.Account
  use AuthDemoWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: Endpoint.subscribe("user:#{socket.assigns.current_user.id}")
    users = Account.get_users(socket.assigns.current_user.id)

    conversations =
      Conversations.get_user_converstions(socket.assigns.current_user.id)

    {:ok,
     assign(socket,
       users: users,
       conversations: conversations,
       current_conversation: nil,
       messages: []
     )}
  end

  def handle_event("new-conversation", %{"id" => id}, socket) do
    found =
      Enum.find(socket.assigns.conversations, fn c ->
        Enum.sort([id, socket.assigns.current_user.id]) == Enum.sort(c.members)
      end)

    case found do
      nil ->
        user = Enum.find(socket.assigns.users, &(&1.id == id))

        {:noreply,
         assign(
           socket,
           current_conversation: %{
             id: :new,
             members: [id, socket.assigns.current_user.id],
             chat_title: user.email,
             sender_id: socket.assigns.current_user.id,
             receiver_id: id
           },
           messages: [],
           form: to_form(Messages.change_message(%Message{}))
         )}

      c ->
        messages = Messages.get_messages_by_conversation(c.id)

        {:noreply,
         assign(socket,
           current_conversation: c,
           messages: messages,
           form: to_form(Messages.change_message(%Message{}))
         )}
    end
  end

  def handle_event("send-message", %{"message" => %{"text" => text}}, socket) do
    if socket.assigns.current_conversation.id == :new do
      new_conversation =
        Map.put(socket.assigns.current_conversation, :last_message, text)
        |> Map.put(:unread_messages, 0)

      {:ok, res} = Conversations.create_conversation(new_conversation)

      new_message =
        %{
          text: text,
          status: 0,
          sender_id: new_conversation.sender_id,
          receiver_id: new_conversation.receiver_id,
          conversation_id: res.id,
          sender_email: socket.assigns.current_user.email
        }

      updated_conversations = [new_conversation | socket.assigns.conversations]
      updated_messages = socket.assigns.messages ++ [new_message]
      Messages.create_message(new_message)
      Endpoint.broadcast("user:#{new_message.receiver_id}", "new_message", new_message)

      {:noreply,
       assign(socket,
         current_conversation: new_conversation,
         conversations: updated_conversations,
         messages: updated_messages,
         form: to_form(Messages.change_message(%Message{}))
       )}
    else
      updated_conversation = Map.put(socket.assigns.current_conversation, :last_message, text)

      {:ok, res} =
        Conversations.update_conversation(updated_conversation)

      new_message =
        %{
          text: text,
          status: 0,
          sender_id: updated_conversation.sender_id,
          receiver_id: updated_conversation.receiver_id,
          conversation_id: res.id,
          sender_email: socket.assigns.current_user.email
        }

      updated_conversations =
        Enum.map(socket.assigns.conversations, fn c ->
          if c.id == res.id do
            %{c | last_message: text, updated_at: res.updated_at}
          else
            c
          end
        end)
        |> Enum.sort_by(& &1.updated_at, :desc)

      updated_messages = socket.assigns.messages ++ [new_message]
      Messages.create_message(new_message)
      Endpoint.broadcast("user:#{new_message.receiver_id}", "new_message", new_message)

      {:noreply,
       assign(socket,
         current_conversation: updated_conversation,
         conversations: updated_conversations,
         messages: updated_messages,
         form: to_form(Messages.change_message(%Message{}))
       )}
    end
  end

  def handle_event("show-conversation", %{"conversation_id" => id}, socket) do
    current_conversation =
      Enum.find(socket.assigns.conversations, &(&1.id == id))
      |> Map.put(:sender_id, socket.assigns.current_user.id)

    receiver_id = Enum.find(current_conversation.members, &(&1 != socket.assigns.current_user.id))
    current_conversation = current_conversation |> Map.put(:receiver_id, receiver_id)

    conversations =
      if current_conversation.unread_messages > 0 do
        Messages.update_read_messages_by_conversation(
          current_conversation.id,
          socket.assigns.current_user.id
        )

        socket.assigns.conversations
        |> Enum.map(fn conversation ->
          updated_conversation =
            if conversation.id == id do
              %{conversation | unread_messages: 0}
            else
              conversation
            end

          updated_conversation
        end)
      else
        socket.assigns.conversations
      end

    messages = Messages.get_messages_by_conversation(current_conversation.id)

    {:noreply,
     assign(socket,
       messages: messages,
       conversations: conversations,
       current_conversation: current_conversation,
       form: to_form(Messages.change_message(%Message{}))
     )}
  end

  def handle_event("validate", %{"message" => message}, socket) do
    changeset =
      %Message{}
      |> Messages.change_message(message)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    current_conversation = socket.assigns.current_conversation

    {found_elem, remaining_elem} =
      socket.assigns.conversations
      |> Enum.find(&(&1.id == message.conversation_id))
      |> (fn
            nil -> {nil, socket.assigns.conversations}
            elem -> {elem, Enum.reject(socket.assigns.conversations, fn c -> c.id == elem.id end)}
          end).()

    unread_messages =
      if current_conversation != nil and current_conversation.id == found_elem.id do
        Messages.update_read_messages_by_conversation(
          current_conversation.id,
          socket.assigns.current_user.id
        )

        found_elem.unread_messages
      else
        found_elem.unread_messages + 1
      end

    conversations =
      if found_elem do
        found_elem = %{
          found_elem
          | last_message: message.text,
            updated_at: DateTime.utc_now(),
            unread_messages: unread_messages
        }

        [found_elem | remaining_elem]
      else
        new_conversation = %{
          id: message.conversation_id,
          members: [message.sender_id, message.receiver_id],
          chat_title: message.sender_email,
          sender_id: socket.assigns.current_user.id,
          receiver_id: message.sender_id,
          last_message: message.text,
          updated_at: DateTime.utc_now(),
          unread_messages: 1
        }

        [new_conversation | remaining_elem]
      end

    messages =
      if current_conversation != nil and message.conversation_id == current_conversation.id do
        socket.assigns.messages ++ [message]
      else
        socket.assigns.messages
      end

    {:noreply, assign(socket, messages: messages, conversations: conversations)}
  end
end

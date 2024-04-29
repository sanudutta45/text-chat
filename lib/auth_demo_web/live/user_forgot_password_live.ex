defmodule AuthDemoWeb.UserForgotPasswordLive do
  use AuthDemoWeb, :live_view

  alias AuthDemo.Account

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm h-full my-20">
      <header class="text-center text-white">
        <div>
          <h1 class="text-lg font-semibold leading-8 text-gray-300">Forgot your password?</h1>
          <p class="mt-2 text-sm leading-6 text-gray-400">
            We'll send a password reset link to your inbox
          </p>
        </div>
        <div class="flex-none"></div>
      </header>

      <.form for={@form} id="reset_password_form" phx-submit="send_email">
        <div class="mt-10 space-y-8 bg-gray-900 text-white rounded-md p-6">
          <div class="w-full">
            <.input
              field={@form[:email]}
              type="email"
              placeholder="Email"
              required
              class="block w-full focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-gray-400  border-gray-700 focus:border-gray-400 bg-gray-800 text-white rounded-md p-2"
            />
          </div>
          <div class="mt-2 flex items-center justify-between gap-6">
            <.button
              phx-disable-with="Sending..."
              class="phx-submit-loading:opacity-75 active:text-white/80 w-full bg-blue-500 hover:bg-blue-700 py-2 px-3 text-sm font-semibold leading-6 text-white rounded-lg"
            >
              Send password reset instructions
            </.button>
          </div>
        </div>
      </.form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"} class="text-gray-400 hover:text-blue-500">Register</.link>
        | <.link href={~p"/users/log_in"} class="text-gray-400 hover:text-blue-500">Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Account.get_user_by_email(email) do
      Account.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end

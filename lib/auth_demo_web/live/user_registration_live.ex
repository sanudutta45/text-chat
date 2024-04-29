defmodule AuthDemoWeb.UserRegistrationLive do
  use AuthDemoWeb, :live_view

  alias AuthDemo.Account
  alias AuthDemo.Account.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm h-full my-20">
      <header class="text-center text-white">
        <div>
          <h1 class="text-lg font-semibold leading-8 text-gray-300">Register for an account</h1>
          <p class="mt-2 text-sm leading-6 text-gray-400">
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-orange-500 hover:underline">
              Sign in
            </.link>
            to your account now.
          </p>
        </div>
      </header>

      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <div class="mt-10 space-y-8 bg-gray-900 text-white rounded-md p-6">
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <div>
            <label for="user_email" class="block text-sm font-semibold leading-6 text-gray-300">
              Email
            </label>
            <.input
              field={@form[:email]}
              type="email"
              required
              class="mt-2 block w-full rounded-lg text-gray-200 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-gray-400 border-gray-700 focus:border-gray-400 bg-gray-800 p-2"
            />
          </div>

          <div>
            <label for="user_password" class="block text-sm font-semibold leading-6 text-gray-300">
              Password
            </label>
            <.input
              field={@form[:password]}
              type="password"
              required
              class="mt-2 block w-full rounded-lg text-gray-200 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-gray-400 border-gray-700 focus:border-gray-400 bg-gray-800 p-2"
            />
          </div>

          <div class="mt-2 flex items-center justify-between gap-6">
            <.button
              phx-disable-with="Creating account..."
              class="rounded-lg bg-blue-500 hover:bg-blue-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80 w-full"
            >
              Create an account
            </.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Account.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Account.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Account.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Account.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Account.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end

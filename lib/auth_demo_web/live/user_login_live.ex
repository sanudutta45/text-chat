defmodule AuthDemoWeb.UserLoginLive do
  use AuthDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm h-full my-20">
      <header class="text-center text-white">
        <div>
          <h1 class="text-lg font-semibold leading-8 text-gray-300">Sign in to account</h1>
          <p class="mt-2 text-sm leading-6 text-gray-400">
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="font-semibold text-orange-500 hover:underline"
            >
              Sign up
            </.link>
            for an account now.
          </p>
        </div>
        <div class="flex-none"></div>
      </header>

      <.form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <div class="mt-10 space-y-8 bg-gray-900 text-white rounded-md p-6">
          <div class="w-full">
            <label for="user_email" class="block text-sm font-semibold leading-6 text-gray-300">
              Email
            </label>
            <.input
              field={@form[:email]}
              type="email"
              required
              class="block w-full focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-gray-400  border-gray-700 focus:border-gray-400 bg-gray-800 text-white rounded-md p-2"
            />
          </div>
          <div class="w-full">
            <label for="user_password" class="block text-sm font-semibold leading-6 text-gray-300">
              Password
            </label>
            <.input
              field={@form[:password]}
              type="password"
              required
              class="block w-full focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-gray-700 phx-no-feedback:focus:border-gray-400  border-gray-700 focus:border-gray-400 bg-gray-800 text-white rounded-md p-2"
            />
          </div>

          <div class="mt-2 flex items-center justify-between gap-6">
            <label class="flex items-center gap-4 text-sm leading-6 text-gray-400">
              <.input
                field={@form[:remember_me]}
                type="checkbox"
                class="rounded border-gray-700 text-gray-300 focus:ring-0"
              /> Keep me logged in
            </label>
            <.link
              href={~p"/users/reset_password"}
              class="text-sm font-semibold text-gray-400 hover:underline"
            >
              Forgot your password?
            </.link>
          </div>
          <div class="mt-2 flex items-center justify-between gap-6">
            <.button
              phx-disable-with="Signing in..."
              class="rounded-lg bg-blue-500 hover:bg-blue-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80 w-full"
            >
              Sign in <span aria-hidden="true">→</span>
            </.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end

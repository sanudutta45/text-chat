defmodule AuthDemoWeb.PageController do
  use AuthDemoWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/chat")
  end
end

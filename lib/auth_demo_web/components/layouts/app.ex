defmodule AuthDemoWeb.Layouts.App do
  alias Phoenix.LiveView.JS

  def toggle_drawer do
    JS.toggle(
      to: "#drawer",
      in:
        {"transition ease-out duration-300", "transform opacity-0 translate-x-[-100%]",
         "transform opacity-100 translate-x-0"},
      out:
        {"transition ease-in duration-200", "transform opacity-100 translate-x-0",
         "transform opacity-0 translate-x-[-100%]"}
    )
  end

  def close_start_conversation do
    JS.toggle(
      to: "#drawer",
      in:
        {"transition ease-out duration-300", "transform opacity-0 translate-x-[-100%]",
         "transform opacity-100 translate-x-0"},
      out:
        {"transition ease-in duration-200", "transform opacity-100 translate-x-0",
         "transform opacity-0 translate-x-[-100%]"}
    )
    |> JS.push("new-conversation")
  end
end

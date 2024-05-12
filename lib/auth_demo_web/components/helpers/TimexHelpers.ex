defmodule AuthDemoWeb.Helpers.TimexHelpers do
  def timeline_date(timeline) do
    case Timex.diff(Timex.now(), timeline, :days) do
      0 ->
        "Today"

      1 ->
        "Yesterday"

      _ ->
        if Timex.diff(Timex.now(), timeline, :week) == 0 do
          {_, currentWeek} = Timex.format(timeline, "{WDfull}")
          currentWeek
        else
          {_, futureTime} = Timex.format(timeline, "{D} {Mshort} {YYYY}")
          futureTime
        end
    end
  end
end

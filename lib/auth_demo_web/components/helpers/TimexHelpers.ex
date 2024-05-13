defmodule AuthDemoWeb.Helpers.TimexHelpers do
  def timeline_date(timeline, timezone) do
    case {is_in_current_week(timeline, timezone), is_yesterday(timeline, timezone)} do
      {0, 0} -> "Yesterday"
      {0, 1} -> "Today"
      {0, _} -> format_date(timeline, "{WDfull}", timezone)
      {-1, 0} -> "Yesterday"
      {-1, 1} -> "Yesterday"
      _ -> format_date(timeline, "{D} {Mshort} {YYYY}", timezone)
    end
  end

  def convert_to_client_timezone(timeline, timezone) do
    Timex.Timezone.convert(timeline, timezone)
  end

  defp client_beginning_of_day(timezone) do
    Timex.beginning_of_day(Timex.now(timezone))
  end

  defp client_begging_of_week(timezone) do
    Timex.beginning_of_week(Timex.now(timezone))
  end

  defp is_in_current_week(timeline, timezone) do
    Timex.compare(
      Timex.beginning_of_week(convert_to_client_timezone(timeline, timezone)),
      client_begging_of_week(timezone)
    )
  end

  def is_on_same_day(timeline_1, timeline_2, timezone) do
    Timex.compare(
      Timex.beginning_of_day(convert_to_client_timezone(timeline_1, timezone)),
      Timex.beginning_of_day(convert_to_client_timezone(timeline_2, timezone))
    )
  end

  defp is_yesterday(timeline, timezone) do
    yesterday = Timex.shift(client_beginning_of_day(timezone), days: -1)

    Timex.compare(
      Timex.beginning_of_day(convert_to_client_timezone(timeline, timezone)),
      yesterday
    )
  end

  def format_date(timeline, format, timezone) do
    {_, formatted_time} = Timex.format(convert_to_client_timezone(timeline, timezone), format)
    formatted_time
  end
end

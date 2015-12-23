defmodule TimeService.Time do
  def get_formatted_utc_time do
    format_time(get_utc_time)
  end

  def get_utc_time do
    :erlang.universaltime
  end

  def format_time({{year, month, day}, {hour, min, sec}}) do
    :io_lib.format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [year, month, day, hour, min, sec])
    |> to_string
  end
end

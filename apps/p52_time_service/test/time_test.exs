defmodule TimeServiceTimeTest do
  use ExUnit.Case
  import TimeService.Time
  doctest TimeService.Time

  test "format time" do
    test_time = {{2015, 1, 1}, {0, 0, 0}}
    assert format_time(test_time) == "2015-01-01 00:00:00"
  end

  test "value returned by get_utc_time is valid shape" do
    assert {{_year, _month, _day}, {_hour, _min, _sec}} = get_utc_time
  end

end

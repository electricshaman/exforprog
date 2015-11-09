defmodule HeartRateWorkerTest do
  use ExUnit.Case
  import Enum
  doctest HeartRate.Worker

  test "Generate intensity scale with step value 1" do
    scale_params = {1, 10, 1}
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(scale_params)
    assert_scale(scale, scale_params)
  end

  test "Generate intensity scale with step value 5 from 0 to 10" do
    scale_params = {0, 10, 5}
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(scale_params)
    assert_scale(scale, scale_params)
  end

  test "Generate intensity scale from step value 5 from 55 to 95" do
    scale_params = {55, 95, 5}
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(scale_params)
    assert_scale(scale, scale_params)
  end

  test "Intensity scale with step value of 0 should return an error" do
    assert {:error, _} = HeartRate.Worker.build_intensity_scale({5, 95, 0})
  end

  defp assert_scale(output, {start, stop, step}) do
    scale_len = (stop - start) / step + 1
    assert length(output) == scale_len
    assert min(output) == start
    assert max(output) == stop
  end

  test "Calculate correct heart rate given age, resting heart rate, and intensity" do
    {age, resting} = {22, 65}
    expected = [{55, 138}, {60, 145}, {65, 151}, {85, 178}, {90, 185}, {95, 191}]

    actual = map(expected, fn({i, exp_hr}) -> {HeartRate.Worker.calculate_hr(i, age, resting), exp_hr} end)
    assert all?(actual, fn({actual_hr, exp_hr}) -> actual_hr == exp_hr end)
  end

end

defmodule HeartRateWorkerTest do
  use ExUnit.Case
  import Enum
  doctest HeartRate.Worker

  test "Generate intensity scale with step value 1" do
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(1, 10, 1)
    assert length(scale) == 10
    assert min(scale) == 1
    assert max(scale) == 10
  end

  test "Generate intensity scale with step value 5 from 0 to 10" do
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(0, 10, 5)
    assert length(scale) == 3
    assert min(scale) == 0
    assert max(scale) == 10
  end

  test "Generate intensity scale from step value 5 from 55 to 95" do
    {:ok, scale} = HeartRate.Worker.build_intensity_scale(55, 95, 5)
    assert_scale(scale, 55, 95, 5)
  end

  test "Intensity scale with step value of 0 should return an error" do
    assert {:error, :invalid_step} = HeartRate.Worker.build_intensity_scale(5, 95, 0)
  end

  defp assert_scale(output, expected_min, expected_max, step) do
    scale_len = (expected_max - expected_min) / step + 1
    assert length(output) == scale_len
    assert min(output) == expected_min
    assert max(output) == expected_max
  end

  test "Calculate correct heart rate given age, resting heart rate, and intensity" do
    {age, resting} = {22, 65}
    expected = [{55, 138}, {60, 145}, {65, 151}, {85, 178}, {90, 185}, {95, 191}]

    actual = map(expected, fn({i, exp_hr}) -> {HeartRate.Worker.calculate_hr(age, resting, i), exp_hr} end)
    assert all?(actual, fn({actual_hr, exp_hr}) -> actual_hr == exp_hr end)
  end

end

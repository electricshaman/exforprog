defmodule KarvonenHeartRateWorkerTest do
  use ExUnit.Case
  import Enum
  doctest KarvonenHeartRate.Worker

  test "Generate intensity scale with step value 1" do
    {:ok, scale} = KarvonenHeartRate.Worker.generate_intensity_scale(1, 10, 1)
    assert length(scale) == 10
    assert min(scale) == 1
    assert max(scale) == 10
  end

  test "Generate intensity scale with step value 5 from 0 to 10" do
    {:ok, scale} = KarvonenHeartRate.Worker.generate_intensity_scale(0, 10, 5)
    assert length(scale) == 3
    assert min(scale) == 0
    assert max(scale) == 10
  end

  test "Generate intensity scale from step value 5 from 55 to 95" do
    {:ok, scale} = KarvonenHeartRate.Worker.generate_intensity_scale(55, 95, 5)
    assert_scale(scale, 55, 95, 5)
  end

  defp assert_scale(output, expected_min, expected_max, step) do
    scale_len = (expected_max - expected_min) / step + 1
    assert length(output) == scale_len
    assert min(output) == expected_min
    assert max(output) == expected_max
  end
end

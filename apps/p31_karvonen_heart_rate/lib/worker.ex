defmodule KarvonenHeartRate.Worker do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([intensity_start, intensity_end, intensity_step]) do
    {:ok, %{}}
  end

  def generate_intensity_scale(range_start, range_end, step) do
    scale = generate_scale(range_start, range_end, step, [])
    {:ok, scale}
  end

  defp generate_scale(current, max, step, acc) when current <= max do
    generate_scale(current+step, max, step, [current|acc])
  end

  defp generate_scale(current, max, step, acc) when current > max do
    Enum.reverse(acc)
  end

  def terminate(reason, state) do
    Logger.warn("Worker terminating: #{inspect reason}")
    :ok
  end
end

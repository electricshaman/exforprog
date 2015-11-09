defmodule HeartRate.Worker do
  use GenServer
  require Logger

  # Client Functions

  def get_hr(age, resting_hr, scale_start, scale_end, scale_step) do
    GenServer.call(__MODULE__, {:hr, age, resting_hr, scale_start, scale_end, scale_step})
  end

  # Server

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    {:ok, %{}}
  end

  def terminate(reason, state) do
    Logger.warn("Heart rate worker terminating: #{inspect reason}")
    :ok
  end

  def handle_call({:hr, age, resting_hr, scale_start, scale_end, scale_step}, _from, state) do
    response = case build_intensity_scale(scale_start, scale_end, scale_step) do
      {:ok, scale} -> build_hr(age, resting_hr, scale)
      other -> other
    end
    {:reply, response, state}
  end

  def build_hr(age, resting_hr, scale) do
    rates = Enum.map(scale, fn i -> calculate_hr(age, resting_hr, i) end)
    {:ok, Enum.zip(scale, rates)}
  end

  def calculate_hr(age, resting_hr, intensity) do
    result = (((220 - age) - resting_hr) * intensity/100) + resting_hr
    :erlang.trunc(Float.round(result, 0))
  end

  def build_intensity_scale(range_start, range_end, step) do
    build_scale(range_start, range_end, step, [])
  end

  defp build_scale(_, _, _step = 0, _),
    do: {:error, :invalid_step}

  defp build_scale(current, max, step, acc) when current <= max do
    build_scale(current+step, max, step, [current|acc])
  end

  defp build_scale(current, max, _step, acc) when current > max do
    {:ok, Enum.reverse(acc)}
  end

end

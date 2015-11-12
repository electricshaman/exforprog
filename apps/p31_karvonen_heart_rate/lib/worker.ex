defmodule HeartRate.Worker do
  use GenServer
  require Logger

  # Client Functions

  def get_hr(age, resting_hr, scale_start, scale_end, scale_step) do
    GenServer.call(__MODULE__, {:get_hr, age, resting_hr, {scale_start, scale_end, scale_step}})
  end

  # Server

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    {:ok, %{}}
  end

  def terminate(reason, _state) do
    Logger.warn("Heart rate worker terminating: #{inspect reason}")
    :ok
  end

  def handle_call({:get_hr, age, resting_hr, scale_params}, _from, state) do
    response = build_intensity_scale(scale_params) |> build_hr(age, resting_hr)
    {:reply, response, state}
  end

  def build_hr(error = {:error, _}, _, _), do: error

  def build_hr({:ok, scale}, age, resting_hr) do
    rates = Enum.map(scale, fn i -> calculate_hr(i, age, resting_hr) end)
    {:ok, Enum.zip(scale, rates)}
  end

  def calculate_hr(intensity, age, resting_hr) do
    round((((220 - age) - resting_hr) * intensity/100) + resting_hr)
  end

  def build_intensity_scale({range_start, range_end, step}) do
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

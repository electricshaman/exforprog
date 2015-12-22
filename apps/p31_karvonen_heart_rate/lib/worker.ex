defmodule HeartRate.Worker do
  use GenServer
  require Logger

  # Client Functions

  def run_prompt do
    {:ok, age} = prompt(:int, "How old are you?")
    {:ok, rest_hr} = prompt(:int, "What is your resting heart rate?")
    {:ok, rates} = get_hr(age, rest_hr, 5, 95, 5)
  end

  def prompt(type, prompt) do
    IO.gets("#{prompt} ")
    |> strip_break
    |> parse_input(type)
  end

  def parse_input(input, :int) when is_bitstring(input) do
    case Integer.parse(input) do
      {num, _} when is_integer(num) -> {:ok, num}
      fail -> {:error, fail}
    end
  end

  def parse_input(input, _), do: {:ok, input}

  def strip_break(input), do: binary_part(input, 0, byte_size(input) - 1)

  def get_hr(age, resting_hr, scale_start, scale_end, scale_step) do
    GenServer.call(__MODULE__, {:get_hr, age, resting_hr, {scale_start, scale_end, scale_step}})
  end

  # Server

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    {:ok, %{}}
  end

  def terminate(reason, state) do
    Logger.warn("Heart rate worker terminating: #{inspect reason}, state: #{inspect state}")
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

  defp build_scale(_current, _max, _step = 0, _acc),
    do: {:error, :invalid_step}

  defp build_scale(current, max, step, acc) when current <= max do
    build_scale(current+step, max, step, [current|acc])
  end

  defp build_scale(current, max, _step, acc) when current > max do
    {:ok, Enum.reverse(acc)}
  end

end

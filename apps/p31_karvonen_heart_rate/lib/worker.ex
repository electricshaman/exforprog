defmodule HeartRate.Worker do
  use GenServer
  require Logger

  @app :p31_karvonen_heart_rate
  @attempt_limit Application.get_env(@app, :invalid_input_attempts)
  @scale_start Application.get_env(@app, :intensity_scale_start)
  @scale_end Application.get_env(@app, :intensity_scale_end)
  @scale_step Application.get_env(@app, :intensity_scale_step)

  # Client Functions

  def start do
    {:ok, [age, rest_hr]} = collect_input
    {:ok, rates} = get_hr(age, rest_hr, @scale_start, @scale_end, @scale_step)

    format_header_for_table([age, rest_hr])
    format_rates_into_table(rates)
  end

  def format_header_for_table(inputs) do
    :io.format("~n")
    :io.format("Resting Pulse: ~-6wAge: ~-3w~n", inputs)
    :io.format("~n")
    :io.format("Intensity    | Rate~n")
    :io.format("-------------|---------~n")
  end

  def format_rates_into_table(rates) when is_list(rates) do
    Enum.each(rates, fn({intensity, rate}) ->
      percentage = to_string(intensity) <> "%"
      :io.format("~-13s| ~-3w bpm~n", [percentage, rate])
    end)
  end

  def collect_input do
    prompts = [{:int, "How old are you?"},
               {:int, "What is your resting heart rate?"}]

    case collect_input_with_prompts(prompts) do
      error = {:error, :failed_to_collect} ->
        IO.puts "You can't be trusted."
        error
      answers -> {:ok, answers}
    end
  end

  def collect_input_with_prompts(prompts) when is_list(prompts) do
    collect_input_with_prompts(prompts, [], 0)
  end

  def collect_input_with_prompts(prompts = [{type, msg}|t], answers, attempts) when attempts < @attempt_limit do
    case prompt(type, msg) do
      {:ok, value} ->
        collect_input_with_prompts(t, [value|answers], attempts)
      {:error, {:invalid_input, input}} ->
        IO.puts("Invalid input: #{input}")
        collect_input_with_prompts(prompts, answers, attempts + 1)
    end
  end

  def collect_input_with_prompts(_prompts, _answers, @attempt_limit) do
    {:error, :failed_to_collect}
  end

  def collect_input_with_prompts([], answers, _attempts), do: Enum.reverse(answers)

  def prompt(type, prompt) do
    IO.gets("#{prompt} ")
    |> strip_break
    |> parse_input(type)
  end

  def parse_input(input, :int) when is_bitstring(input) do
    case Integer.parse(input) do
      {num, _} when is_integer(num) -> {:ok, num}
      _ -> {:error, {:invalid_input, input}}
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

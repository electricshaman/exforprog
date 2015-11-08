defmodule KarvonenHeartRate do
  use Application

  @intsy_range_start  Application.get_env(:karvonen_heart_rate, :intensity_range_start)
  @intsy_range_end    Application.get_env(:karvonen_heart_rate, :intensity_range_end)
  @intsy_step         Application.get_env(:karvonen_heart_rate, :intensity_range_step)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(KarvonenHeartRate.Worker, [[@intsy_range_start, @intsy_range_end, @intsy_step]])
    ]

    opts = [strategy: :one_for_one, name: KarvonenHeartRate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

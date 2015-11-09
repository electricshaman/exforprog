defmodule HeartRate do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(HeartRate.Worker, [[]])
    ]

    opts = [strategy: :one_for_one, name: HeartRate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

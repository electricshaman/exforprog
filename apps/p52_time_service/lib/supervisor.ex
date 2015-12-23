defmodule TimeService do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      :ranch.child_spec(:http, 100, :ranch_tcp, [{:port, 8080}, {:nodelay, true}], TimeService.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: TimeService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

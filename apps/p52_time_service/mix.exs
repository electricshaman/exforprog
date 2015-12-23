defmodule TimeService.Mixfile do
  use Mix.Project

  def project do
    [app: :p52_time_service,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ranch],
     mod: {TimeService, []}]
  end

  defp deps do
    [{:ranch, "~> 1.2"}]
  end
end

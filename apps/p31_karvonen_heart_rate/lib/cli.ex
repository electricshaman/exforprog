defmodule HeartRate.CLI do
  def main(args) do
    HeartRate.Worker.start
  end
end

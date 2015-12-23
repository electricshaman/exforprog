defmodule HeartRate.CLI do
  def main(_args) do
    HeartRate.Worker.start
  end
end

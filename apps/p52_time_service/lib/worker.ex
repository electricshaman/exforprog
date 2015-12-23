defmodule TimeService.Worker do
  require Logger
  import TimeService.Time, only: [get_formatted_utc_time: 0]

  #@behaviour :ranch_protocol

  # Server

  def start_link(listener, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [listener, socket, transport, opts])
    {:ok, pid}
  end

  def init(listener, socket, transport, _opts) do
    :ok = :ranch.accept_ack(listener)
    response = format_response_body(get_formatted_utc_time) |> build_response
    transport.send(socket, response)
    transport.close(socket)
  end

  def format_response_body(formatted_time) do
    ~s({ "currentTime": "#{formatted_time}" })
  end

  def build_response(body) do
    """
    HTTP/1.0 200 OK
    Content-Type: application/json
    Content-Length: #{byte_size(body)}
    Connection: close

    #{body}
    """
  end
end

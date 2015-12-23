defmodule TimeServiceWorkerTest do
  use ExUnit.Case
  import TimeService.Worker
  doctest TimeService.Worker

  test "build response" do
    test_body = ~s({ "currentTime": "2015-01-01 00:00:00" })

    assert build_response(test_body) == """
    HTTP/1.0 200 OK
    Content-Type: application/json
    Content-Length: 40
    Connection: close

    { "currentTime": "2015-01-01 00:00:00" }
    """
  end

  test "format response body" do
    test_time = "2015-01-01 00:00:00"
    assert format_response_body(test_time) == ~s({ "currentTime": "2015-01-01 00:00:00" })
  end
end

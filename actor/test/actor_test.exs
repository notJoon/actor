defmodule ActorTest do
  use ExUnit.Case
  import Actor

  test "processing messages in batch when queue reaches batch size" do
    value = 20
    batch_size = 3
    pid = new(value: value, batch_size: batch_size)

    send(pid, {:set, 30})
    send(pid, {:get, self()})
    send(pid, {:send, {:add, 10}})

    :timer.sleep(100)

    refute_receive {:result, _}, 1000

    send(pid, {:get, self()})

    assert_receive {:result, result}, 3000
    assert result == 40
  end
end

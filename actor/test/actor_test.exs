defmodule ActorTest do
  use ExUnit.Case

  test "generate new actor" do
    assert Actor.new(0) |> is_pid()
  end

  test "generate new actor and get its state value" do
    pid_1 = Actor.new(0)
    pid_2 = Actor.new(42)

    assert Actor.get(pid_1) == 0
    assert Actor.get(pid_2) == 42
  end

  test "update actor state" do
    pid = Actor.new(0)

    assert Actor.get(pid) == 0

    Actor.set(pid, 42)

    assert Actor.get(pid) == 42
  end

  @tag :skip
  test "broadcast message to all subscribers when receive a message" do
    pid = Actor.new(0)

    sub1 = spawn_link(fn -> receive do _ -> end end)
    sub2 = spawn_link(fn -> receive do _ -> end end)

    send(pid, {:subscribe, sub1})
    send(pid, {:subscribe, sub2})

    send(pid, {:message, 42})

    Process.sleep(1000)

    assert_receive 42
    assert_receive 42
  end
end

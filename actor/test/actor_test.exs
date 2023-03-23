defmodule ActorTest do
  use ExUnit.Case

  test "generate new actor" do
    pid = Actor.new(0)
    assert Actor.get(pid) == 0
  end

  test "set new state" do
    pid = Actor.new(0)

    new_state = Actor.set(pid, 1)
    assert new_state == 1

    new_state = Actor.set(pid, 2)
    assert new_state == 2
  end

  test "generate multiple actors" do
    pid1 = Actor.new(0)
    pid2 = Actor.new(1)

    assert Actor.get(pid1) == 0
    assert Actor.get(pid2) == 1
  end

  @tag :skip
  test "remove activated actor" do
    pid = Actor.new(0)

    assert Actor.get(pid) == 0
    Actor.kill(pid)
    assert Actor.get(pid) == :killed
  end

  @tag :skip
  test "if try to set new state on dead actor, raise error" do
    pid = Actor.new(0)
    Actor.kill(pid)

    assert_raise RuntimeError, "Actor has killed", fn ->
      Actor.set(pid, 1)
    end
  end

  @tag :skip
  test "if try to kill dead actor, raise error" do
    pid = Actor.new(0)
    Actor.kill(pid)

    assert_raise RuntimeError, "Actor has killed before", fn ->
      Actor.kill(pid)
    end
  end

  test "add other actor as subscriber" do
    pid1 = Actor.new()
    pid2 = Actor.new()
    pid3 = Actor.new()

    Actor.subscribe(pid1, pid2)
    Actor.subscribe(pid1, pid3)

    Actor.set(pid1, 1)

    assert Actor.get(pid2) == 1
    assert Actor.get(pid3) == 1
  end
end

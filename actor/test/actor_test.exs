defmodule ActorTest do
  use ExUnit.Case
  doctest Actor

  test "start and stop actor" do
    pid = Actor.start_link(0)
    assert Actor.stop(pid, :normal) == :ok
  end

  test "get and set actor state" do
    pid = Actor.start_link(0)
    assert Actor.get(pid) == 0
    assert Actor.set(pid, 1) == :ok
    assert Actor.get(pid) == 1
  end

  test "generate multiple actors and stop them" do
    actors = Enum.map(1..10, fn _ -> Actor.start_link(0) end)
    Enum.each(actors, fn pid -> Actor.stop(pid, :normal) end)
  end

  test "generate multiple actors and set their states" do
    actors = Enum.map(1..10, fn _ -> Actor.start_link(0) end)
    Enum.each(actors, fn pid -> Actor.set(pid, 1) end)
    Enum.each(actors, fn pid -> assert Actor.get(pid) == 1 end)
    Enum.each(actors, fn pid -> Actor.stop(pid, :normal) end)
  end
end

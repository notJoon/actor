defmodule ActorTest do
  use ExUnit.Case, async: true
  alias Actor

  setup do
    {:ok, pid} = Actor.start_link(value: 20)
    {:ok, %{pid: pid}}
  end

  test "initial value should be 20", %{pid: pid} do
    assert Actor.get() == 20
  end

  test "set should update the value", %{pid: pid} do
    Actor.set(20)
    assert Actor.get() == 20
  end

  test "add operation and update actor's value", %{pid: pid} do
    Actor.send({:add, 10})
    assert Actor.get() == 30
  end

  test "sub operation and update actor's value", %{pid: pid} do
    Actor.send({:sub, 10})
    assert Actor.get() == 10
  end

  test "mul operation and update actor's value", %{pid: pid} do
    Actor.send({:mul, 10})
    assert Actor.get() == 200
  end

  test "div operation and update actor's value", %{pid: pid} do
    Actor.send({:div, 10})
    assert Actor.get() == 2
  end
end

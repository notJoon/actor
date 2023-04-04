defmodule ActorTest do
  use ExUnit.Case
  alias Actor, as: Actor

  test "actor messaging" do
    {:ok, actor1} = Actor.start_link(value: 0, name: :actor1)
    {:ok, actor2} = Actor.start_link(value: 0, name: :actor2)

    Actor.set(actor1, 5)
    assert Actor.get(actor1) == 5

    Actor.send_message(actor1, {:add, 5})
    assert Actor.get(actor1) == 10

    Actor.send_to(:actor1, {:sub, 5})
    assert Actor.get(actor1) == 5

    Actor.send_to(:actor2, {:mul, 2})
    assert Actor.get(actor2) == 0
  end
end

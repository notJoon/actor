defmodule Actor do
  defstruct state: 0, mailbox: [], subscribers: MapSet.new()

  # generate new actor
  @spec new(state :: integer) :: pid
  def new(state \\ 0) do
    spawn_link(__MODULE__, :loop, [state])
  end

  @spec loop(state :: integer) :: no_return
  def loop(state) do
    receive do
      {:get, pid} ->
        send(pid, state)
        loop(state)

      {:set, pid, new_state} ->
        send(pid, new_state)
        loop(new_state)

      {:kill, pid} ->
        send(pid, :killed)
        kill(pid)

      # TODO
      # {:subscribe, pid} ->
      #   subscribers = subscribe(self(), pid)
      #   loop(%{state | subscribers: subscribers})

      # {:unsubscribe, pid} ->
      #   subscribers = unsubscribe(self(), pid)
      #   loop(%{state | subscribers: subscribers})
    end
  end

  @spec get(pid :: pid) :: integer
  def get(pid) do
    pid |> send({:get, self()})
    receive do
      state -> state
    end
  end

  @spec set(pid :: pid, new_state :: integer) :: integer
  def set(pid, new_state) do
    pid |> send({:set, self(), new_state})

    if get(pid) == :killed do
      raise "Actor is killed"
    end

    receive do
      state -> state
    end
  end

  def kill(pid) do
    if get(pid) == :killed do
      raise "Actor has killed before"
    end
    pid |> send({:kill, self()})
  end
end

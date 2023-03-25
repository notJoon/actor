defmodule Actor do
  defstruct state: 0, mailbox: :queue.new(), subscribers: MapSet.new()

  @spec new(state :: integer) :: pid
  def new(state) do
    spawn_link(__MODULE__, :loop, [%{state: state, mailbox: :queue.new(), subscribers: MapSet.new()}])
  end

  @spec loop(state :: integer) :: no_return
  def loop(state) do
    receive do
      {:get, pid} ->
        send(pid, %{state | state: state[:state]})
        loop(%{state | state: state})

      {:set, pid, new_state} ->
        send(pid, new_state)
        loop(%{state | state: new_state})

      {:subscribe, pid} ->
        subscribers = MapSet.put(state[:subscribers], pid)
        loop(%{state | subscribers: subscribers})

      {:unsubscribe, pid} ->
        subscribers = MapSet.delete(state[:subscribers], pid)
        loop(%{state | subscribers: subscribers})

      {:message, value} ->
        if MapSet.size(state[:subscribers]) == 0 do
          message = :queue.in(value, state[:mailbox])
          loop(%{state | mailbox: message})
        else
          Enum.each(state[:subscribers], fn pid ->
            send(pid, value)
          end)
          loop(state)
        end

      _ ->
        loop(state)
    end
  end

  @spec get(pid :: pid) :: integer
  def get(pid) do
    pid |> send({:get, self()})

    receive do
      state -> state[:state]
    end
  end

  @spec set(pid :: pid, new_state :: integer) :: integer
  def set(pid, new_state) do
    pid |> send({:set, self(), new_state})

    receive do
      state -> state
    end
  end

  def subscribers(pid) do
    state = Process.get(pid, :state)
    state[:subscribers]
  end
end

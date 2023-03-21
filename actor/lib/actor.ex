defmodule Actor do
  def start_link(state) do
    spawn_link(__MODULE__, :loop, [state])
  end

  def loop(state) do
    receive do
      {:get, caller} ->
        send(caller, state)
        loop(state)

      {:set, new_state} ->
        loop(new_state)

      {:stop, caller} ->
        raise "Actor stopped"
    end
  end

  def get(pid) do
    pid |> send({:get, self()})
    receive do
      state -> state
    after 1000 ->
      :timeout
    end
  end

  def set(pid, new_state) do
    pid |> send({:set, new_state})
    :ok
  end

  def stop(pid, reason) do
    pid |> send({:stop, reason})
    :ok
  end
end

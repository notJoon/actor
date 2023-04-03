defmodule Actor do

  @moduledoc """
  A simple actor that can perform arithmetic operations on a value.
  """
  use GenServer

  @ops [:add, :sub, :mul, :div]

  # Client API

  @spec start_link(value: integer) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec get() :: integer()
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @spec set(integer()) :: :ok
  def set(value) do
    GenServer.cast(__MODULE__, {:set, value})
  end

  @spec send({atom(), integer()}) :: :ok
  def send(msg) do
    GenServer.cast(__MODULE__, {:send, msg})
  end

  # Server API

  def init(args) do
    {:ok, args[:value]}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set, new_value}, _state) do
    {:noreply, new_value}
  end

  def handle_cast({:send, msg}, state) do
    new_state = case msg do
      {op, x} when op in @ops ->
        do_arithmetic(state, op, x)

      _ ->
        state
    end

    {:noreply, new_state}
  end

  def handle_cast(_, state) do
    {:noreply, state}
  end

  defp do_arithmetic(state, op, x) when is_integer(x) do
    case op do
      :add -> state + x
      :sub -> state - x
      :mul -> state * x
      :div -> state / x
    end
  end

  defp do_arithmetic(_, :div, 0), do: raise "Division by zero"
end

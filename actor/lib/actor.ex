defmodule Actor do

  @moduledoc """
  A simple actor that can perform arithmetic operations on a value.
  """
  use GenServer

  @ops [:add, :sub, :mul, :div]

  # Client API

  @spec start_link(value: number, name: any) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: {:via, :gproc, {:n, :l, args[:name]}})
  end

  @spec get(pid()) :: number()
  def get(pid) do
    GenServer.call(pid, :get)
  end

  @spec set(pid(), number()) :: :ok
  def set(pid, value) do
    GenServer.cast(pid, {:set, value})
  end

  @spec send_message(pid(), {atom(), number()}) :: :ok
  def send_message(pid, msg) do
    GenServer.cast(pid, {:send_message, msg})
  end

  @spec send_to(atom(), {atom(), number()}) :: :ok | {:error, :not_found}
  def send_to(name, msg) do
    case :gproc.whereis_name({:n, :l, name}) do
      nil ->
        {:error, :not_found}

      pid ->
        send_message(pid, msg)
        :ok
    end
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

  def handle_cast({:send_message, msg}, state) do
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

  defp do_arithmetic(state, op, x) when is_number(x) do
    case op do
      :add -> state + x
      :sub -> state - x
      :mul -> state * x
      :div -> trunc(state / x)
    end
  end

  defp do_arithmetic(_, :div, 0), do: raise "Division by zero"
end

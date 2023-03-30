defmodule Actor do
  defstruct value: nil, mailbox: :queue.new(), subscribers: MapSet.new()

  @ops [:add, :sub, :mul, :div]
  @batch 5

  def new(args, batch_size \\ @batch) do
    init_state = %__MODULE__{value: args[:value]}
    spawn_link(fn -> loop(self(), init_state, batch_size) end)
  end

  def get(pid) do
    pid.value
  end

  def set(pid, new_value) do
    %Actor{pid | value: new_value}
  end

  def loop(pid, state, batch_size) do
    new_state =
      receive do
        message ->
          stored_state = store_message(state, message)

          if :queue.len(stored_state.mailbox) >= batch_size do
            Process.send(pid, :process_mailbox, [])
          end

          stored_state
      end

    loop(pid, new_state, batch_size)
  end

  def handle_message(state) do
    case :queue.out(state.mailbox) do
      {:empty, _} ->
        state

      {{:value, message}, new_mailbox} ->
        new_state =
          case message do
            {:get, caller} ->
              send(caller, {:ok, state.value})
              %Actor{state | mailbox: new_mailbox}

            {:set, new_value} ->
              %Actor{state | value: new_value, mailbox: new_mailbox}

            {:send, msg} ->
              case msg do
                {op, x} when op in @ops ->
                  %Actor{
                    state
                    | value: do_arithmetic(state.value, op, x),
                      mailbox: new_mailbox
                  }

                _ ->
                  {:error, "unknown message"}
              end

            {:error, reason} ->
              IO.inspect("Error: #{reason}")
              %Actor{state | mailbox: new_mailbox}

            :process_mailbox ->
              handle_message(%Actor{state | mailbox: new_mailbox})

            _ ->
              {:error, "unknown message"}
              %Actor{state | mailbox: new_mailbox}
          end

        new_state
    end
  end

  # TODO 현재 `{:ok, {:error, "divided to zero"}}`를 반환하고 있음.
  #      이를 `{:error, "divided to zero"}`로 변경해야 함.
  defp do_arithmetic(_, :div, 0), do: {:error, "divided to zero"}

  defp do_arithmetic(value, op, x) when is_integer(x) do
    case op do
      :add -> value + x
      :sub -> value - x
      :mul -> value * x
      :div -> value / x
    end
  end

  defp store_message(state, message) do
    new_mailbox = :queue.in(message, state.mailbox)
    %__MODULE__{state | mailbox: new_mailbox}
  end
end

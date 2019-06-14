defmodule Table.TableServer do
  @moduledoc """
  A game server process that holds a `Table`
  """

  use GenServer

  require Logger

  alias Table.{State, Deck}

  @timeout :timer.minutes(10)

  # Client (Public) Interface

  @doc """
  Spawns a new table server process registered under the given `table_id`.
  """
  def start_link(table_id) do
    GenServer.start_link(
      __MODULE__,
      table_id,
      name: via_tuple(table_id)
    )
  end

  def deal_card(table_id) do
    GenServer.call(via_tuple(table_id), :deal_card)
  end

  def reshuffle(table_id) do
    GenServer.call(via_tuple(table_id), :reshuffle)
  end

  def count_deck(table_id) do
    GenServer.call(via_tuple(table_id), :count_deck)
  end

  def get_dealer_seat_index(table_id) do
    GenServer.call(via_tuple(table_id), :get_dealer_seat_index)
  end

  def move_dealer_to_seat({table_id, new_seat_index}) do
    GenServer.call(via_tuple(table_id), {:move_dealer_to_seat, new_seat_index})
  end

  @doc """
  Returns a tuple used to register and lookup a table server process by id.
  """
  def via_tuple(table_id) do
    {:via, Registry, {Table.TableRegistry, table_id}}
  end

  @doc """
  Returns the `pid` of the table server process registered under the
  given `table_id`, or `nil` if no process is registered.
  """
  def table_pid(table_id) do
    table_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server Callbacks

  def init(table_id) do
    table =
      case :ets.lookup(:tables_table, table_id) do
        [] ->
          table = State.new()
          :ets.insert(:tables_table, {table_id, table})
          table

        [{^table_id, table}] ->
          table
      end

    Logger.info("Spawned table server process named '#{table_id}'.")

    {:ok, table, @timeout}
  end

  def handle_call(:deal_card, _from, %State{deck: []} = table_state) do
    {:reply, %Deck.Card{}, table_state, @timeout}
  end

  def handle_call(:deal_card, _from, %State{deck: [card_dealt | rest_of_deck]} = table_state) do
    table_state = %{table_state | deck: rest_of_deck}
    :ets.insert(:tables_table, {my_table_id(), table_state})
    {:reply, card_dealt, table_state, @timeout}
  end

  def handle_call(:count_deck, _from, %State{deck: deck} = table_state) do
    {:reply, Enum.count(deck), table_state, @timeout}
  end

  def handle_call(:reshuffle, _from, table_state) do
    deck = Table.Deck.new()
    table_state = %{table_state | deck: deck}
    :ets.insert(:tables_table, {my_table_id(), table_state})
    {:reply, :ok, table_state, @timeout}
  end

  def handle_call(:get_dealer_seat_index, _from, table_state) do
    {:reply, table_state.dealer_seat_index, table_state, @timeout}
  end

  def handle_call({:move_dealer_to_seat, new_seat_index}, _from, table_state) do
    table_state = State.move_dealer_to_seat(table_state, new_seat_index)
    {:reply, {:ok, new_seat_index}, table_state, @timeout}
  end

  def handle_info(:timeout, table_state) do
    IO.puts("Table timed out, table stopping")
    {:stop, {:shutdown, :timeout}, table_state}
  end

  def terminate({:shutdown, :timeout}, _table_state) do
    :ets.delete(:tables_table, my_table_id())
    :ok
  end

  def terminate(_reason, _table) do
    :ok
  end

  def stop_table(table_id) do
    :ets.delete(:tables_table, table_id)
  end

  defp my_table_id do
    Registry.keys(Table.TableRegistry, self()) |> List.first()
  end
end

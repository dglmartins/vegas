defmodule Table.TableServer do
  @moduledoc """
  A game server process that holds a `Table`
  """

  use GenServer

  require Logger

  alias Table.{State}
  # :timer.seconds(5)
  @refresh_interval 100

  @timeout :timer.minutes(10)

  # Client (Public) Interface

  @doc """
  Spawns a new table server process registered under the given `table_id`, small_blind, ante.
  """
  def start_link(table_id, min_bet, ante, game_type) do
    GenServer.start_link(
      __MODULE__,
      {table_id, min_bet, ante, game_type},
      name: via_tuple(table_id)
    )
  end

  def get_dealer_seat(table_id) do
    GenServer.call(via_tuple(table_id), :get_dealer_seat)
  end

  # def move_dealer_to_seat({table_id, new_seat}) do
  #   GenServer.call(via_tuple(table_id), {:move_dealer_to_seat, new_seat})
  # end
  #
  # def move_dealer_to_left(table_id) do
  #   GenServer.call(via_tuple(table_id), :move_dealer_to_left)
  # end

  def get_seat_map(table_id) do
    GenServer.call(via_tuple(table_id), :get_seat_map)
  end

  def get_tally(table_id) do
    GenServer.call(via_tuple(table_id), :get_tally)
  end

  def get_game_type(table_id) do
    GenServer.call(via_tuple(table_id), :get_game_type)
  end

  def get_pre_action_min_bet_ante(table_id) do
    GenServer.call(via_tuple(table_id), :get_pre_action_min_bet_ante)
  end

  def join_table({table_id, player, desired_seat}) do
    GenServer.call(via_tuple(table_id), {:join_table, player, desired_seat})
  end

  def leave_table({table_id, seat}) do
    GenServer.call(via_tuple(table_id), {:leave_table, seat})
  end

  # def start_hand(table_id) do
  #   GenServer.call(via_tuple(table_id), :start_hand)
  # end

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

  def init({table_id, min_bet, ante, game_type}) do
    table =
      case :ets.lookup(:tables_table, table_id) do
        [] ->
          table = State.new(min_bet, ante, game_type, table_id)
          :ets.insert(:tables_table, {table_id, table})
          table

        [{^table_id, table}] ->
          table
      end

    Logger.info("Spawned table server process named '#{table_id}'.")

    {:ok, table, @timeout}
  end

  def handle_call(:get_tally, _from, table_state) do
    {:reply, tally(table_state), table_state, @timeout}
  end

  def handle_info(:server_next_step, %{status: :waiting} = table_state) do
    IO.puts("Current status waiting...")
    {:noreply, table_state}
  end

  def handle_info(:server_next_step, %{status: :hand_to_start} = table_state) do
    IO.puts("Current status #{table_state.status}...")
    table_state = Dealer.start_hand(table_state)
    Process.send_after(self(), :server_next_step, @refresh_interval)
    {:noreply, table_state}
  end

  def handle_info(:server_next_step, %{status: :dealing_hole_cards} = table_state) do
    IO.puts("Current status #{table_state.status}...")
    table_state = Dealer.deal_hole_cards(table_state)
    Process.send_after(self(), :server_next_step, @refresh_interval)
    {:noreply, table_state}
  end

  def handle_info(:server_next_step, %{status: :posting_antes} = table_state) do
    IO.puts("Current status #{table_state.status}...")
    table_state = Action.post_antes(table_state)
    Process.send_after(self(), :server_next_step, @refresh_interval)
    {:noreply, table_state}
  end

  def handle_info(:server_next_step, table_state) do
    # IO.puts("Current status #{table_state.status}...")
    # table_state = Dealer.start_hand(table_state)
    # Process.send_after(self(), :server_next_step, @refresh_interval)
    {:noreply, table_state}
  end

  # defp schedule_refresh do
  #   Process.send_after(self(), :refresh, @refresh_interval)
  # end

  def handle_call(:get_dealer_seat, _from, table_state) do
    {:reply, table_state.dealer_seat, table_state, @timeout}
  end

  # def handle_call({:move_dealer_to_seat, new_seat}, _from, table_state) do
  #   table_state = SeatHelpers.move_dealer_to_seat(table_state, new_seat)
  #   :ets.insert(:tables_table, {my_table_id(), table_state})
  #   {:reply, {:ok, table_state.dealer_seat}, table_state, @timeout}
  # end
  #
  # def handle_call(:move_dealer_to_left, _from, table_state) do
  #   table_state = SeatHelpers.move_dealer_to_left(table_state)
  #   :ets.insert(:tables_table, {my_table_id(), table_state})
  #   {:reply, {:ok, table_state.dealer_seat}, table_state, @timeout}
  # end

  def handle_call(:get_seat_map, _from, table_state) do
    {:reply, table_state.seat_map, table_state, @timeout}
  end

  def handle_call(:get_game_type, _from, table_state) do
    {:reply, table_state.game_type, table_state, @timeout}
  end

  def handle_call(:get_pre_action_min_bet_ante, _from, table_state) do
    {:reply, {table_state.pre_action_min_bet, table_state.ante}, table_state, @timeout}
  end

  def handle_call({:join_table, player, desired_seat}, _from, table_state) do
    {status, table_state} = State.join_table(table_state, player, desired_seat)
    :ets.insert(:tables_table, {my_table_id(), table_state})
    Process.send_after(self(), :server_next_step, @refresh_interval)
    {:reply, status, table_state, @timeout}
  end

  def handle_call({:leave_table, seat}, _from, table_state) do
    table_state = State.leave_table(table_state, seat)
    :ets.insert(:tables_table, {my_table_id(), table_state})
    {:reply, :ok, table_state, @timeout}
  end

  # def handle_call(:start_hand, _from, table_state) do
  #   table_state = Dealer.start_hand(table_state)
  #   :ets.insert(:tables_table, {my_table_id(), table_state})
  #   {:reply, :ok, table_state, @timeout}
  # end

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

  def tally(%{status: status} = table_state) do
    table_state
  end
end

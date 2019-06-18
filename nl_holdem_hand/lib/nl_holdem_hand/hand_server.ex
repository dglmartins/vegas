defmodule NlHoldemHand.HandServer do
  @moduledoc """
  A game server process that holds a `Hand`
  """

  use GenServer

  require Logger

  alias NlHoldemHand.{State, Play}

  @timeout :timer.minutes(10)

  # Client (Public) Interface

  @doc """
  Spawns a new hand server process registered under the given hand_id, table_id, min_bet, ante, seat_map, dealer_seat.
  """
  def start_link(hand_id, table_id, min_bet, ante, seat_map, dealer_seat) do
    GenServer.start_link(
      __MODULE__,
      {hand_id, table_id, min_bet, ante, seat_map, dealer_seat},
      name: via_tuple(hand_id)
    )
  end

  def deal_hole_card({hand_id, card, seat}) do
    GenServer.call(via_tuple(hand_id), {:deal_hole_card, card, seat})
  end

  @doc """
  Returns a tuple used to register and lookup a hand server process by id.
  """
  def via_tuple(hand_id) do
    {:via, Registry, {NlHoldemHand.HandRegistry, hand_id}}
  end

  @doc """
  Returns the `pid` of the hand server process registered under the
  given `hand_id`, or `nil` if no process is registered.
  """
  def hand_pid(hand_id) do
    hand_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server Callbacks

  def init({hand_id, table_id, min_bet, ante, seat_map, dealer_seat}) do
    hand =
      case :ets.lookup(:hands_table, hand_id) do
        [] ->
          hand = State.new(hand_id, table_id, min_bet, ante, seat_map, dealer_seat)
          :ets.insert(:hands_table, {hand_id, hand})
          hand

        [{^hand_id, hand}] ->
          hand
      end

    Logger.info("Spawned hand server process named '#{hand_id}'.")
    {:ok, hand, @timeout}
  end

  def handle_call({:deal_hole_card, card, seat}, _from, hand_state) do
    hand_state = Play.deal_hole_card(hand_state, card, seat)
    {:reply, :ok, hand_state, @timeout}
  end

  def handle_info(:timeout, hand_state) do
    IO.puts("Hand timed out, hand stopping")
    {:stop, {:shutdown, :timeout}, hand_state}
  end

  def terminate({:shutdown, :timeout}, _hand_state) do
    :ets.delete(:hands_table, my_hand_id())
    :ok
  end

  def terminate(_reason, _hand) do
    :ok
  end

  def stop_hand(hand_id) do
    :ets.delete(:hands_table, hand_id)
  end

  defp my_hand_id do
    Registry.keys(NlHoldemHand.HandRegistry, self()) |> List.first()
  end
end

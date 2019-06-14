defmodule Deck.DeckServer do
  @moduledoc """
  A game server process that holds a `Deck`
  """

  use GenServer

  require Logger

  alias Deck.Create

  @timeout :timer.minutes(10)

  # Client (Public) Interface

  @doc """
  Spawns a new deck server process registered under the given `deck_id`.
  """
  def start_link(deck_id) do
    GenServer.start_link(
      __MODULE__,
      deck_id,
      name: via_tuple(deck_id)
    )
  end

  def deal_card(deck_id) do
    GenServer.call(via_tuple(deck_id), :deal_card)
  end

  def reshuffle(deck_id) do
    GenServer.call(via_tuple(deck_id), :reshuffle)
  end

  def count_deck(deck_id) do
    GenServer.call(via_tuple(deck_id), :count_deck)
  end

  @doc """
  Returns a tuple used to register and lookup a deck server process by id.
  """
  def via_tuple(deck_id) do
    {:via, Registry, {Deck.DeckRegistry, deck_id}}
  end

  @doc """
  Returns the `pid` of the deck server process registered under the
  given `deck_id`, or `nil` if no process is registered.
  """
  def deck_pid(deck_id) do
    deck_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server Callbacks

  def init(deck_id) do
    deck =
      case :ets.lookup(:decks_table, deck_id) do
        [] ->
          deck = Create.new()
          :ets.insert(:decks_table, {deck_id, deck})
          deck

        [{^deck_id, deck}] ->
          deck
      end

    Logger.info("Spawned deck server process named '#{deck_id}'.")

    {:ok, deck, @timeout}
  end

  def handle_call(:deal_card, _from, []) do
    {:reply, %Deck.Card{}, [], @timeout}
  end

  def handle_call(:deal_card, _from, [card_dealt | rest_of_deck]) do
    :ets.insert(:decks_table, {my_deck_id(), rest_of_deck})
    {:reply, card_dealt, rest_of_deck, @timeout}
  end

  def handle_call(:count_deck, _from, deck) do
    {:reply, Enum.count(deck), deck, @timeout}
  end

  def handle_call(:reshuffle, _from, _deck) do
    deck = Create.new()
    :ets.insert(:decks_table, {my_deck_id(), deck})
    {:reply, :ok, deck, @timeout}
  end

  def handle_info(:timeout, deck) do
    IO.puts("Deck timed out, deck stopping")
    {:stop, {:shutdown, :timeout}, deck}
  end

  def terminate({:shutdown, :timeout}, _game) do
    :ets.delete(:decks_table, my_deck_id())
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  def stop_deck(deck_id) do
    :ets.delete(:decks_table, deck_id)
  end

  defp my_deck_id do
    Registry.keys(Deck.DeckRegistry, self()) |> List.first()
  end
end

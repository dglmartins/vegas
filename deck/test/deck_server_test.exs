defmodule DeckServerTest do
  use ExUnit.Case
  doctest Deck.DeckServer

  alias Deck.{DeckServer, Create}

  test "spawning a deck server process" do
    deck_id = generate_deck_id()

    assert {:ok, _pid} = DeckServer.start_link(deck_id)
  end

  test "a deck process is registered under a unique hand_id" do
    deck_id = generate_deck_id()

    assert {:ok, _pid} = DeckServer.start_link(deck_id)

    assert {:error, _reason} = DeckServer.start_link(deck_id)
  end

  test "deals a card" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    card = DeckServer.deal_card(deck_id)

    assert card.rank in 2..14
    assert card.suit in [:hearts, :clubs, :diamonds, :spades]
    assert DeckServer.count_deck(deck_id) == 51
  end

  test "deck is empty after 52 cards" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    for _deal <- 1..52 do
      DeckServer.deal_card(deck_id)
    end

    card = DeckServer.deal_card(deck_id)

    assert card.rank == nil
    assert card.suit == nil
  end

  test "stores initial state in ETS when started" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    assert [{^deck_id, deck}] = :ets.lookup(:decks_table, deck_id)

    [first_card | _rest_of_deck] = deck

    assert first_card == DeckServer.deal_card(deck_id)
  end

  test "gets its initial state from ETS if previously stored" do
    deck_id = generate_deck_id()

    deck = Create.new()

    [_dealt_card | rest_of_deck] = deck

    :ets.insert(:decks_table, {deck_id, rest_of_deck})

    {:ok, _pid} = DeckServer.start_link(deck_id)

    assert DeckServer.count_deck(deck_id) == 51
  end

  test "updates state in ETS when card is dealt" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    _card = DeckServer.deal_card(deck_id)

    [{^deck_id, ets_deck}] = :ets.lookup(:decks_table, deck_id)

    assert Enum.count(ets_deck) == 51
  end

  describe "deck_pid" do
    test "returns a PID if it has been registered" do
      deck_id = generate_deck_id()

      {:ok, pid} = DeckServer.start_link(deck_id)
      assert ^pid = DeckServer.deck_pid(deck_id)
    end

    test "returns nil if the deck does not exist" do
      refute DeckServer.deck_pid("nonexistent-deck")
    end
  end

  defp generate_deck_id() do
    "deck-#{:rand.uniform(1_000_000)}"
  end
end

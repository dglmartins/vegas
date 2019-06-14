defmodule DeckServerTest do
  use ExUnit.Case
  doctest Deck.DeckServer

  alias Deck.DeckServer

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

  test "reshuffles a deck" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    card = DeckServer.deal_card(deck_id)

    assert DeckServer.count_deck(deck_id) == 51

    DeckServer.reshuffle(deck_id)

    assert DeckServer.count_deck(deck_id) == 52
  end

  test "deck is empty after 52 cards" do
    deck_id = generate_deck_id()

    {:ok, _pid} = DeckServer.start_link(deck_id)

    for deal <- 1..52 do
      DeckServer.deal_card(deck_id)
    end

    card = DeckServer.deal_card(deck_id)

    assert card.rank == nil
    assert card.suit == nil
  end

  describe "deck_pid" do
    test "returns a PID if it has been registered" do
      hand_id = generate_deck_id()

      {:ok, pid} = DeckServer.start_link(hand_id)
      assert ^pid = DeckServer.deck_pid(hand_id)
    end

    test "returns nil if the deck does not exist" do
      refute DeckServer.deck_pid("nonexistent-deck")
    end
  end

  defp generate_deck_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

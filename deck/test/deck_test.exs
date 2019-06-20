defmodule DeckTest do
  use ExUnit.Case
  doctest Deck

  alias Deck.DeckServer

  test "create_deck spawns a deck server process and is unique if created again" do
    deck_id = generate_deck_id()

    assert {:ok, _pid} = Deck.create_deck(deck_id)
    assert {:error, {:already_started, _pid}} = Deck.create_deck(deck_id)
  end

  test "deal_card deals a card" do
    deck_id = generate_deck_id()

    {:ok, _pid} = Deck.create_deck(deck_id)

    card = Deck.deal_card(deck_id)

    assert card.rank in 2..14
    assert card.suit in [:hearts, :clubs, :diamonds, :spades]
    assert DeckServer.count_deck(deck_id) == 51
  end

  test "stops a deck" do
    deck_id = generate_deck_id()

    assert {:ok, _pid} = Deck.create_deck(deck_id)
    assert {:error, {:already_started, _pid}} = Deck.create_deck(deck_id)

    assert :ok = Deck.stop_deck(deck_id)
    assert {:ok, _pid} = Deck.create_deck(deck_id)
  end

  describe "deck_pid" do
    test "returns a PID if it has been registered" do
      deck_id = generate_deck_id()

      {:ok, pid} = Deck.create_deck(deck_id)
      assert ^pid = Deck.deck_pid(deck_id)
    end

    test "returns nil if the deck does not exist" do
      refute Deck.deck_pid("nonexistent-deck")
    end
  end

  test "gets deck_ids" do
    deck_id_one = generate_deck_id()
    deck_id_two = generate_deck_id()

    {:ok, _pid} = Deck.create_deck(deck_id_one)
    {:ok, _pid} = Deck.create_deck(deck_id_two)

    _card_deck_one = Deck.deal_card(deck_id_one)
    _card_deck_two = Deck.deal_card(deck_id_two)

    assert DeckServer.count_deck(deck_id_one) == 51
    assert DeckServer.count_deck(deck_id_two) == 51

    assert deck_id_one in Deck.deck_ids()
    assert deck_id_two in Deck.deck_ids()
  end

  defp generate_deck_id() do
    "deck-#{:rand.uniform(1_000_000)}"
  end
end

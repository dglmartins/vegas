defmodule Deck do
  alias Deck.{DeckSupervisor, DeckServer}

  defdelegate create_deck(deck_id), to: DeckSupervisor
  defdelegate deck_pid(deck_id), to: DeckServer
  defdelegate deck_ids(), to: DeckSupervisor
  defdelegate deal_card(deck_id), to: DeckServer
  defdelegate reshuffle(deck_id), to: DeckServer
  defdelegate stop_deck(deck_id), to: DeckSupervisor
end

defmodule Deck do
  alias Deck.Functions

  defdelegate new(), to: Functions
  defdelegate deal_card(deck), to: Functions
end

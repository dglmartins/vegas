defmodule Deck.Card do
  defstruct rank: nil, suit: nil

  def new(rank, suit) do
    %Deck.Card{rank: rank, suit: suit}
  end
end

defmodule Table.Deck.Card do
  defstruct rank: nil, suit: nil, show: false

  def new(rank, suit) do
    %Table.Deck.Card{rank: rank, suit: suit}
  end
end

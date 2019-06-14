defmodule Table.Deck do
  alias Table.Deck.Card

  def new() do
    for rank <- 2..14, suit <- [:hearts, :clubs, :diamonds, :spades] do
      Card.new(rank, suit)
    end
    |> Enum.shuffle()
  end
end

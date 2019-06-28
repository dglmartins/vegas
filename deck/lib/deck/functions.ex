defmodule Deck.Functions do
  def new() do
    for rank <- 2..14, suit <- [:hearts, :clubs, :diamonds, :spades] do
      Card.new(rank, suit)
    end
    |> Enum.shuffle()
  end

  def deal_card([first_card | rest_of_deck]) do
    {first_card, rest_of_deck}
  end

  def deal_card([]) do
    {nil, []}
  end
end

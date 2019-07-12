defmodule NlHoldemHand.Dealer.Deal do
  def deal_hole_cards(table_state) do
    table_state
    |> HoleCards.deal([false, false])
  end

  def deal_flop(%{community_cards: []} = table_state) do
    CommunityCards.deal(table_state, 3)
  end

  def deal_flop(table_state) do
    IO.puts("Cannot deal flop with community cards already dealt")
    table_state
  end

  def deal_turn(%{community_cards: [_card1, _card2, _card3]} = table_state) do
    CommunityCards.deal(table_state, 1)
  end

  def deal_turn(table_state) do
    IO.puts("Cannot deal turn without 3 community cards already dealt")
    table_state
  end

  def deal_river(%{community_cards: [_card1, _card2, _card3, _card4]} = table_state) do
    CommunityCards.deal(table_state, 1)
  end

  def deal_river(table_state) do
    IO.puts("Cannot deal river without 4 community cards already dealt")
    table_state
  end
end

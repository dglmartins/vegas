defmodule Dealer.Deal do
  def deal_hole_cards(%{game_type: :nl_holdem, status: :dealing_hole_cards} = table_state) do
    NlHoldemHand.Deal.deal_hole_cards(table_state)
  end
end

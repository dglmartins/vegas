defmodule Table.Dealer.HoleCards do
  def deal(table_state, :nl_holdem = _game_type) do
    NlHoldemHand.Dealer.deal_hole_cards()
  end
end

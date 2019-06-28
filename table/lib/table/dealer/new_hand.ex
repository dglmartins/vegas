defmodule Table.Dealer.NewHand do
  def start(table_state, :nl_holdem = _game_type) do
    NlHoldemHand.start_hand(table_state)
  end
end

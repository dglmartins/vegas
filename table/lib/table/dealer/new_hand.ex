defmodule Table.Dealer.NewHand do
  def start_hand(%{game_type: :nl_holdem} = table_state, hand_id) do
    NlHoldemHand.start_hand(table_state, hand_id)
  end
end

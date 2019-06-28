defmodule NlHoldemHand do
  alias NlHoldemHand.Dealer
  defdelegate start_hand(table_state, current_hand_id), to: Dealer
end

defmodule Dealer do
  alias Dealer.{StartHand, Deal}
  defdelegate start_hand(table_state), to: StartHand
  defdelegate deal_hole_cards(table_state), to: Deal
end

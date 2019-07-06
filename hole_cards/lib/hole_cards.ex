defmodule HoleCards do
  alias HoleCards.Deal
  defdelegate deal(table_state, card_show_list), to: Deal
end

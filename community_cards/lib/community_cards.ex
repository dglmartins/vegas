defmodule CommunityCards do
  alias CommunityCards.Deal
  defdelegate deal(table_state, number_of_cards), to: Deal
end

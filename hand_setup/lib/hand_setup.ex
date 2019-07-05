defmodule HandSetup do
  alias HandSetup.Setup
  defdelegate new(table_state, current_hand_id), to: Setup
end

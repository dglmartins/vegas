defmodule Table.Dealer do
  alias Table.State

  # def start_hand(%{game_type: :nl_holdem} = table_state, hand_id) do
  #   NlHoldemHand.start_hand(table_state, hand_id)
  # end
  #
  # def post_antes(table_state) do
  #   table_state
  #   |> Action.post_antes()
  #   |> process_post_antes()
  # end
  #
  # def process_post_antes(%{status: :end_hand_no_showdown} = table_state) do
  #   table_state
  #   |> process_no_showdown()
  #   |> State.move_dealer_to_left()
  #   |> start_hand()
  # end
end

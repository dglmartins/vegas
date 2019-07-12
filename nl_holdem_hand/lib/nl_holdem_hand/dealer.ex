defmodule NlHoldemHand.Dealer do
  alias NlHoldemHand.Dealer.Deal

  def start_hand(table_state, current_hand_id) do
    table_state
    |> HandSetup.new(current_hand_id)
    |> Deal.deal_hole_cards()
  end

  # def post_antes(%State{ante: ante} = hand_state) do
  # end
  #
  # def post_blinds(%{sb_seat: sb_seat, bb_seat: bb_seat, sb: sb, bb: bb} = hand_state) do
  # end
  #
  # def deal_flop(hand_state) do
  # end
  # def deal_turn(hand_state) do
  # end
  #
  # def deal_river(hand_state) do
  # end
  # def pre_flop_action(hand_state) do
  #
  # end
  #
  # def post_flop_action(hand_state) do
  #
  # end
  #
  # def turn_action(hand_state) do
  #
  # end
  #
  # def river_action(hand_state) do
  #
  # end
  #
  # def put_chips_in_pot(%State{seat_map: seat_map, pots: pots} = hand_state) do
  # end

  # bet (table_state, desired_bet_value, seat)
  # seat
  # |> check_turn(table_state)
  # |> is_all_in(seat)
  # |> check_min_bet(desired_bet_value)
  # |> debit_player_chips
  # |> allocate_into_main_side_pots
  # |> update_bet_to_call
  # |> update_min_raise
  # |> update_next_to_act
  # |> update_last_to_act
end

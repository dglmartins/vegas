defmodule NlHoldemHand.Dealer do
  alias NlHoldemHand.SeatHelpers

  def deal_hole_cards(
        %{seat_map: seat_map, dealer_seat: dealer_seat, status: :dealing_hole_cards} = table_state
      ) do
    dealer_cards_count = Enum.count(seat_map[dealer_seat].cards)
    next_seat_to_deal = SeatHelpers.get_next_taken_seat(dealer_seat, seat_map)

    deal_hole_cards(table_state, dealer_cards_count, next_seat_to_deal)
  end

  def deal_hole_cards(%{status: status} = table_state) do
    IO.puts("Cannot deal hole cards when status is #{to_string(status)}")
    table_state
  end

  defp deal_hole_cards(
         %{dealer_seat: dealer_seat} = table_state,
         dealer_cards_count,
         next_seat_to_deal
       )
       when dealer_cards_count < 2 do
    new_table_state = deal_hole_card(table_state, next_seat_to_deal)
    new_seat_map = new_table_state.seat_map

    next_seat_to_deal = SeatHelpers.get_next_taken_seat(next_seat_to_deal, new_seat_map)

    dealer_cards_count = Enum.count(new_seat_map[dealer_seat].cards)

    deal_hole_cards(new_table_state, dealer_cards_count, next_seat_to_deal)
  end

  defp deal_hole_cards(table_state, 2, _next_seat_to_deal) do
    %{table_state | status: :posting_blinds_antes}
  end

  defp deal_hole_card(%{seat_map: seat_map, deck: deck} = table_state, seat) do
    {card, rest_of_deck} = Deck.deal_card(deck)
    player = seat_map[seat]
    new_seat_map = Map.put(seat_map, seat, %{player | cards: [card | player.cards]})
    %{table_state | seat_map: new_seat_map, deck: rest_of_deck}
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

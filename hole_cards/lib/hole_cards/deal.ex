defmodule HoleCards.Deal do
  @deal_accepted_status [:active]
  def deal(
        %{seat_map: seat_map, dealer_seat: dealer_seat, status: :dealing_hole_cards} =
          table_state,
        card_show_list
      ) do
    dealer_cards_count = Enum.count(seat_map[dealer_seat].cards)
    num_hole_cards_to_deal = Enum.count(card_show_list)

    next_seat_to_deal =
      SeatHelpers.get_next_taken_seat(dealer_seat, seat_map, @deal_accepted_status)

    deal(
      table_state,
      card_show_list,
      num_hole_cards_to_deal,
      dealer_cards_count,
      next_seat_to_deal
    )
  end

  def deal(%{status: status} = table_state, _card_show_list) do
    IO.puts("Cannot deal hole cards when status is #{to_string(status)}")
    table_state
  end

  defp deal(
         %{dealer_seat: dealer_seat} = table_state,
         card_show_list,
         num_hole_cards_to_deal,
         dealer_cards_count,
         next_seat_to_deal
       )
       when dealer_cards_count < num_hole_cards_to_deal do
    card_show_status = Enum.at(card_show_list, dealer_cards_count)
    table_state = deal_hole_card(table_state, card_show_status, next_seat_to_deal)
    seat_map = table_state.seat_map

    next_seat_to_deal =
      SeatHelpers.get_next_taken_seat(next_seat_to_deal, seat_map, @deal_accepted_status)

    dealer_cards_count = Enum.count(seat_map[dealer_seat].cards)

    deal(
      table_state,
      card_show_list,
      num_hole_cards_to_deal,
      dealer_cards_count,
      next_seat_to_deal
    )
  end

  defp deal(
         table_state,
         _card_show_list,
         num_hole_cards_to_deal,
         num_hole_cards_to_deal,
         _next_seat_to_deal
       ) do
    %{table_state | status: :posting_antes}
  end

  defp deal_hole_card(
         %{seat_map: seat_map, deck: deck} = table_state,
         card_show_status,
         seat
       ) do
    {card, rest_of_deck} = Deck.deal_card(deck)
    card = %{card | show: card_show_status}
    player = seat_map[seat]
    seat_map = Map.put(seat_map, seat, %{player | cards: player.cards ++ [card]})
    %{table_state | seat_map: seat_map, deck: rest_of_deck}
  end
end

defmodule Action.Antes do
  def post_antes(
        %{status: :posting_blinds_antes, seat_map: seat_map, dealer_seat: dealer_seat} =
          table_state
      ) do
    first_to_post = SeatHelpers.get_next_taken_seat(dealer_seat, seat_map)
    post_ante(table_state, first_to_post)
  end

  defp post_ante(
         %{dealer_seat: dealer_seat, ante: ante, seat_map: seat_map} = table_state,
         dealer_seat
       ) do
    player =
      seat_map[dealer_seat]
      |> Player.commit_chips_to_pot(ante)

    %{table_state | seat_map: Map.put(seat_map, dealer_seat, player), bet_to_call: ante}
  end

  defp post_ante(
         %{dealer_seat: dealer_seat, ante: ante, seat_map: seat_map} = table_state,
         seat
       ) do
    player =
      seat_map[seat]
      |> Player.commit_chips_to_pot(ante)

    table_state = %{table_state | seat_map: Map.put(seat_map, seat, player)}

    next_to_post = SeatHelpers.get_next_taken_seat(seat, seat_map)

    post_ante(table_state, next_to_post)
  end
end

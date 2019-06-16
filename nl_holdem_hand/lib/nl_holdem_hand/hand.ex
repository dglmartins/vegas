defmodule NlHoldemHand.Hand do
  defstruct pots: [],
            sb: nil,
            bb: nil,
            ante: nil,
            flop_cards: [],
            turn_card: nil,
            river_card: nil,
            seat_with_action: nil,
            last_to_act: nil,
            seat_map: %{},
            min_raise: nil,
            table_id: nil,
            current_bet_round: :pre_flop,
            dealer_seat: nil

  def new(seat_map) do
    seat_map =
      seat_map
      |> filter_empty_seats()
      |> put_cards_into_seat_map()

    %NlHoldemHand.Hand{seat_map: seat_map}
  end

  defp filter_empty_seats(seat_map) do
    Enum.filter(seat_map, fn {_seat, player} ->
      player != :empty_seat
    end)
  end

  defp put_cards_into_seat_map(seat_map) do
    Enum.reduce(seat_map, %{}, fn {seat, player}, acc ->
      Map.put(acc, seat, Map.put(player, :cards, []))
    end)
  end
end

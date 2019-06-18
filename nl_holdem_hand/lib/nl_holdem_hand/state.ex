defmodule NlHoldemHand.State do
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
            hand_id: nil,
            current_bet_round: :pre_flop,
            dealer_seat: nil

  def new(hand_id, table_id, min_bet, ante, seat_map, dealer_seat) do
    seat_map =
      seat_map
      |> filter_empty_seats()
      |> Enum.into(%{})

    %NlHoldemHand.State{
      hand_id: hand_id,
      table_id: table_id,
      bb: min_bet,
      sb: min_bet / 2,
      ante: ante,
      seat_map: seat_map,
      dealer_seat: dealer_seat
    }
  end

  defp filter_empty_seats(seat_map) do
    Enum.filter(seat_map, fn {_seat, player} ->
      player != :empty_seat
    end)
  end
end

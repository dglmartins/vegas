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
            dealer_seat: nil,
            sb_seat: nil,
            bb_seat: nil,
            bet_to_call: nil

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
      dealer_seat: dealer_seat,
      min_raise: min_bet,
      seat_with_action: get_first_to_act_first_round(dealer_seat, seat_map),
      sb_seat: get_next_taken_seat(dealer_seat, seat_map),
      bb_seat: get_bb_seat(dealer_seat, seat_map),
      last_to_act: get_bb_seat(dealer_seat, seat_map),
      bet_to_call: min_bet
    }
  end

  def get_next_taken_seat(seat_number, seat_map) when seat_number <= 10 do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, seat_map, _seat_taken?) when seat_number == 11 do
    get_next_taken_seat(1, seat_map, Map.has_key?(seat_map, 1))
  end

  def get_next_taken_seat(seat_number, seat_map, false = _seat_taken?) do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, _seat_map, true = _seat_taken?) do
    seat_number
  end

  def get_bb_seat(dealer_seat, seat_map) do
    dealer_seat
    |> get_next_taken_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end

  def get_first_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_bb_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end

  def filter_empty_seats(seat_map) do
    Enum.filter(seat_map, fn {_seat, player} ->
      player != :empty_seat
    end)
  end

  def leave_hand(hand_state, seat) do
    leave_hand(hand_state, seat, Map.has_key?(hand_state.seat_map, seat))
  end

  defp leave_hand(%NlHoldemHand.State{seat_map: seat_map} = state, seat, true = _seat_taken?) do
    player = %{seat_map[seat] | status: :sitting_out}
    %{state | seat_map: Map.put(seat_map, seat, player)}
  end

  defp leave_hand(state, _seat, false = _seat_taken?) do
    state
  end
end

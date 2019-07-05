defmodule NlHoldemHand.Setup do
  def new(%{dealer_seat: nil} = table_state, current_hand_id) do
    IO.puts("No dealer")
    table_state
  end

  def new(%{seat_map: seat_map} = table_state, current_hand_id) do
    active_seat_map = seat_map |> Enum.filter(fn {_seat, player} -> player.status == :active end)
    enough_players? = Enum.count(active_seat_map) >= 2

    new(table_state, current_hand_id, enough_players?)
  end

  def new(
        %{seat_map: seat_map, dealer_seat: dealer_seat} = table_state,
        current_hand_id,
        true = _enough_players?
      ) do
    %{
      table_state
      | seat_with_action: SeatSetup.get_first_to_act_first_round(dealer_seat, seat_map),
        sb_seat: SeatSetup.get_sb_seat(dealer_seat, seat_map),
        bb_seat: SeatSetup.get_bb_seat(dealer_seat, seat_map),
        last_to_act: SeatSetup.get_last_to_act_first_round(dealer_seat, seat_map),
        deck: Deck.new(),
        current_hand_id: current_hand_id,
        status: :dealing_hole_cards
    }
  end

  def new(table_state, _current_hand_id, false = _enough_players?) do
    IO.puts("Not enough players, need at least 2 active players")
    table_state
  end
end

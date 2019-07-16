defmodule HandSetup.Setup do
  @accepted_start_hand_status [:hand_to_start]

  alias HandSetup.SeatSetup

  def new(
        %{seat_map: seat_map, dealer_seat: dealer_seat, status: status} = table_state,
        current_hand_id
      )
      when status in @accepted_start_hand_status do
    IO.puts(current_hand_id)

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

  def new(table_state, _current_hand_id) do
    IO.puts("Table not ready to start hand")
    table_state
  end
end

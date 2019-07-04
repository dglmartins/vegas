defmodule Table.State do
  defstruct dealer_seat: nil,
            status: :waiting,
            hand_history: [],
            pre_action_min_bet: nil,
            ante: nil,
            game_type: nil,
            pots: [],
            deck: nil,
            community_cards: [],
            seat_with_action: nil,
            last_to_act: nil,
            seat_map: %{},
            min_raise: nil,
            table_id: nil,
            hand_id: nil,
            current_bet_round: nil,
            sb_seat: nil,
            bb_seat: nil,
            full_bet_to_call: nil,
            current_hand_id: nil

  # deck_pid: nil
  @accepted_dealer_status [:active]
  def new(pre_action_min_bet, ante, game_type) do
    %Table.State{
      # seat_map: SeatMap.new_empty_table(),
      ante: ante,
      pre_action_min_bet: pre_action_min_bet,
      game_type: game_type,
      full_bet_to_call: pre_action_min_bet,
      min_raise: pre_action_min_bet
    }
  end

  def move_dealer_to_seat(%Table.State{} = table_state, new_dealer_seat)
      when not is_integer(new_dealer_seat) or new_dealer_seat > 10 or new_dealer_seat < 1 do
    table_state
  end

  def move_dealer_to_seat(%Table.State{seat_map: seat_map} = table_state, new_dealer_seat) do
    is_seat_taken? = Map.has_key?(seat_map, new_dealer_seat)
    move_dealer_to_seat(table_state, new_dealer_seat, is_seat_taken?)
  end

  def move_dealer_to_seat(
        %Table.State{seat_map: seat_map} = table_state,
        new_dealer_seat,
        true = is_seat_taken?
      ) do
    is_active_seat? = seat_map[new_dealer_seat].status == :active
    move_dealer_to_seat(table_state, new_dealer_seat, is_seat_taken?, is_active_seat?)
  end

  def move_dealer_to_seat(%Table.State{} = table_state, _new_dealer_seat, false = _is_seat_taken?) do
    IO.puts("No on sitting there")
    table_state
  end

  def move_dealer_to_seat(
        %Table.State{} = table_state,
        new_dealer_seat,
        true = _is_seat_taken?,
        true = _is_active_seat?
      ) do
    %{table_state | dealer_seat: new_dealer_seat}
  end

  def move_dealer_to_seat(
        %Table.State{} = table_state,
        _new_dealer_seat,
        _is_seat_taken?,
        false = _is_active_seat?
      ) do
    IO.puts("No active player sitting there")
    table_state
  end

  def move_dealer_to_left(%Table.State{dealer_seat: nil} = table_state), do: table_state

  def move_dealer_to_left(
        %Table.State{dealer_seat: dealer_seat, seat_map: seat_map} = table_state
      ) do
    next_seat = SeatHelpers.get_next_taken_seat(dealer_seat, seat_map, @accepted_dealer_status)
    move_dealer_to_left(table_state, next_seat)
  end

  def move_dealer_to_left(
        table_state,
        :no_other_seats
      ) do
    table_state
  end

  def move_dealer_to_left(
        table_state,
        next_seat
      ) do
    %{table_state | dealer_seat: next_seat}
  end

  def join_table(%{seat_map: seat_map} = table_state, player, desired_seat)
      when desired_seat in 1..10 do
    empty_seat? = !Map.has_key?(seat_map, desired_seat)
    join_table(table_state, player, desired_seat, empty_seat?)
  end

  def join_table(table_state, _player, _desired_seat) do
    table_state
  end

  def join_table(%{seat_map: seat_map} = table_state, player, desired_seat, true = _empty_seat?) do
    {:ok, %{table_state | seat_map: Map.put(seat_map, desired_seat, player)}}
  end

  def join_table(table_state, _player, _desired_seat, _false = _empty_seat?) do
    IO.puts("seat taken")
    {:seat_taken, table_state}
  end

  def leave_table(%{seat_map: seat_map} = table_state, seat) do
    seat_taken? = Map.has_key?(seat_map, seat)
    leave_table(table_state, seat, seat_taken?)
    %{table_state | seat_map: Map.delete(seat_map, seat)}
  end

  def leave_table(%{seat_map: seat_map} = table_state, seat, true = _seat_taken?) do
    %{table_state | seat_map: Map.delete(seat_map, seat)}
  end

  def leave_table(table_state, _seat, false = _seat_taken?) do
    table_state
  end
end

defmodule Table.State do
  defstruct dealer_seat: nil,
            status: :waiting,
            hand_history: [],
            pre_action_min_bet: nil,
            ante: nil,
            game_type: nil,
            pots: [%Pot{}],
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
            bet_to_call: 0,
            current_hand_id: nil,
            turn_time_left: nil

  # deck_pid: nil
  @accepted_dealer_status [:active]
  def new(pre_action_min_bet, ante, game_type) do
    %Table.State{
      # seat_map: SeatMap.new_empty_table(),
      ante: ante,
      pre_action_min_bet: pre_action_min_bet,
      game_type: game_type,
      min_raise: pre_action_min_bet
    }
  end

  def join_table(%{seat_map: seat_map} = table_state, player, desired_seat)
      when desired_seat in 1..10 do
    empty_seat? = !Map.has_key?(seat_map, desired_seat)
    join_table(table_state, player, desired_seat, empty_seat?)
  end

  def join_table(table_state, _player, _desired_seat) do
    table_state
  end

  def join_table(
        %{seat_map: seat_map, status: :waiting} = table_state,
        player,
        desired_seat,
        true = empty_seat?
      ) do
    enough_to_start? = Enum.count(seat_map) >= 2
    join_table(table_state, player, desired_seat, empty_seat?, enough_to_start?)
    # {:ok, %{table_state | seat_map: Map.put(seat_map, desired_seat, player)}}
  end

  def join_table(%{seat_map: seat_map} = table_state, player, desired_seat, true = _empty_seat?) do
    {:ok, %{table_state | seat_map: Map.put(seat_map, desired_seat, player)}}
  end

  def join_table(table_state, _player, _desired_seat, _false = _empty_seat?) do
    IO.puts("seat taken")
    {:seat_taken, table_state}
  end

  def join_table(
        %{seat_map: seat_map, status: :waiting} = table_state,
        player,
        desired_seat,
        true = _empty_seat?,
        true = _enough_to_start?
      ) do
    {:ok,
     %{table_state | seat_map: Map.put(seat_map, desired_seat, player), status: :starting_hand}}
  end

  def join_table(
        %{seat_map: seat_map, status: :waiting} = table_state,
        player,
        desired_seat,
        true = _empty_seat?,
        false = _enough_to_start
      ) do
    {:ok, %{table_state | seat_map: Map.put(seat_map, desired_seat, player)}}
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

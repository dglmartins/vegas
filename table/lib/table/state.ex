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
            bet_to_call: nil

  # deck_pid: nil

  def new(pre_action_min_bet, ante, game_type) do
    %Table.State{
      # seat_map: SeatMap.new_empty_table(),
      ante: ante,
      pre_action_min_bet: pre_action_min_bet,
      game_type: game_type,
      bet_to_call: pre_action_min_bet,
      min_raise: pre_action_min_bet
    }
  end

  def move_dealer_to_seat(%Table.State{} = state, new_dealer_seat)
      when not is_integer(new_dealer_seat) or new_dealer_seat > 10 or new_dealer_seat < 1 do
    state
  end

  def move_dealer_to_seat(%Table.State{} = state, new_dealer_seat) do
    %{state | dealer_seat: new_dealer_seat}
  end

  def move_dealer_to_left(%Table.State{dealer_seat: nil} = state), do: state

  def move_dealer_to_left(%Table.State{dealer_seat: 10} = state) do
    %{state | dealer_seat: 1}
  end

  def move_dealer_to_left(%Table.State{dealer_seat: new_dealer_seat} = state) do
    %{state | dealer_seat: new_dealer_seat + 1}
  end

  def join_table(%{seat_map: seat_map} = table, player, desired_seat)
      when desired_seat in 1..10 do
    empty_seat? = !Map.has_key?(seat_map, desired_seat)
    join_table(table, player, desired_seat, empty_seat?)
  end

  def join_table(table, _player, _desired_seat) do
    table
  end

  def join_table(%{seat_map: seat_map} = table, player, desired_seat, true = _empty_seat?) do
    {:ok, %{table | seat_map: Map.put(seat_map, desired_seat, player)}}
  end

  def join_table(table, _player, _desired_seat, _false = _empty_seat?) do
    IO.puts("seat taken")
    {:seat_taken, table}
  end

  def leave_table(%{seat_map: seat_map} = table, seat) do
    seat_taken? = Map.has_key?(seat_map, seat)
    leave_table(table, seat, seat_taken?)
    %{table | seat_map: Map.delete(seat_map, seat)}
  end

  def leave_table(%{seat_map: seat_map} = table, seat, true = _seat_taken?) do
    %{table | seat_map: Map.delete(seat_map, seat)}
  end

  def leave_table(table, _seat, false = _seat_taken?) do
    table
  end
end

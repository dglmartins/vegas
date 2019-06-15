defmodule Table.State do
  alias Table.{SeatMap, Deck}

  defstruct seat_map: nil,
            dealer_seat: nil,
            deck: nil,
            status: :waiting,
            hand_history: [],
            min_bet: nil,
            ante: nil,
            game_type: nil

  # deck_pid: nil

  def new(min_bet, ante, game_type) do
    %Table.State{
      seat_map: SeatMap.new_empty_table(),
      deck: Deck.new(),
      ante: ante,
      min_bet: min_bet,
      game_type: game_type
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
    empty_seat? = seat_map[desired_seat] == :empty_seat
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

  def leave_table(%{seat_map: seat_map} = table, seat)
      when seat in 1..10 do
    %{table | seat_map: Map.put(seat_map, seat, :empty_seat)}
  end

  def leave_table(table, _seat) do
    table
  end
end

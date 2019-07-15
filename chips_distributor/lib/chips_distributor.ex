defmodule ChipsDistributor do
  def distribute(%{status: :end_hand_no_showdown, seat_map: seat_map, pots: pots} = table_state) do
    only_active_seat = seat_map |> get_only_active_seat()
    player = seat_map[only_active_seat]
    [only_pot] = pots
    chip_count = player.chip_count + only_pot.pot_value
    player = %{player | chip_count: chip_count}

    seat_map = Map.put(seat_map, only_active_seat, player)

    %{table_state | seat_map: seat_map}
  end

  def distribute(%{status: :distributing_chips, seat_map: seat_map, pots: pots} = table_state) do
    seat_map =
      pots
      |> Enum.reduce(seat_map, fn pot, acc_seat_map ->
        num_winners = Enum.count(pot.winners)
        chips_per_winner = trunc(pot.pot_value / num_winners)
        chips_remaining = rem(pot.pot_value, num_winners)
        distribute_pot_chips(pot.winners, chips_per_winner, chips_remaining, acc_seat_map)
      end)

    %{table_state | seat_map: seat_map}
  end

  defp get_only_active_seat(seat_map) do
    seat_map
    |> Enum.filter(fn {_seat, player} -> player.status == :active end)
    |> Enum.map(fn {seat, _player} -> seat end)
    |> Enum.at(0)
  end

  def distribute_pot_chips(
        [current_winning_seat | []],
        chips_per_winner,
        chips_remaining,
        seat_map
      ) do
    player = seat_map[current_winning_seat]
    chip_count = player.chip_count + chips_per_winner + chips_remaining
    player = %{player | chip_count: chip_count}
    Map.put(seat_map, current_winning_seat, player)
  end

  def distribute_pot_chips(
        [current_winning_seat | other_winning_seats],
        chips_per_winner,
        chips_remaining,
        seat_map
      ) do
    player = seat_map[current_winning_seat]
    chip_count = player.chip_count + chips_per_winner
    player = %{player | chip_count: chip_count}
    seat_map = Map.put(seat_map, current_winning_seat, player)
    distribute_pot_chips(other_winning_seats, chips_per_winner, chips_remaining, seat_map)
  end
end

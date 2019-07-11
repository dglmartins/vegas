defmodule Pot do
  @accepted_distribute_pot_status [:end_hand_no_showdown, :deal_to_showdown, :action_round_ended]
  @accepted_reset_pot_bets_status [:starting_hand]

  def reset_pots_bets(%{seat_map: seat_map, status: status} = table_state)
      when status in @accepted_reset_pot_bets_status do
    seat_map = reset_chips_to_current_pot(seat_map)
    pots = [%{seats: [:all_active], pot_value: 0}]

    %{table_state | pots: pots, seat_map: seat_map, bet_to_call: 0}
  end

  def reset_pots_bets(%{seat_map: seat_map, status: status} = table_state) do
    IO.puts("Table not expecting reset to pots")
    table_state
  end

  def distribute_to_pots(%{seat_map: seat_map, status: status} = table_state)
      when status in @accepted_distribute_pot_status do
    table_state
    |> return_excess_bet()
    |> create_side_pots()
    |> filter_zero_value_side_pots()
    |> add_remaining_active_pot()
  end

  def distribute_to_pots(table_state) do
    IO.puts("Table not expecting distribute to pots")
    table_state
  end

  defp filter_zero_value_side_pots(%{pots: [active_pot | side_pots]} = table_state) do
    side_pots =
      side_pots
      |> Enum.filter(fn side_pot ->
        side_pot.pot_value != 0
      end)

    pots = [active_pot] ++ side_pots

    %{table_state | pots: pots}
  end

  def reset_chips_to_current_pot(seat_map) do
    seat_map
    |> Stream.map(fn {seat, player} ->
      player = %{player | chips_to_pot_current_bet_round: 0}
      {seat, player}
    end)
    |> Enum.into(%{})
  end

  defp add_remaining_active_pot(
         %{seat_map: seat_map, pots: [%{seats: [:all_active], pot_value: pot_value} | side_pots]} =
           table_state
       ) do
    pots =
      [%{seats: [:all_active], pot_value: pot_value + get_active_pot_value(seat_map)}] ++
        side_pots

    seat_map = reset_chips_to_current_pot(seat_map)

    %{table_state | seat_map: seat_map, pots: pots}
  end

  defp get_active_pot_value(seat_map) do
    seat_map
    |> Enum.reduce(0, fn {seat, player}, active_pot_value ->
      active_pot_value + player.chips_to_pot_current_bet_round
    end)
  end

  defp create_side_pots(%{seat_map: seat_map} = table_state) do
    sorted_seats_all_in = get_all_in_seats_current_round(seat_map)
    create_side_pots(table_state, sorted_seats_all_in)
  end

  defp create_side_pots(table_state, []) do
    table_state
  end

  defp create_side_pots(
         %{
           seat_map: seat_map,
           pots: [%{seats: [:all_active], pot_value: pot_value} | _side_pots] = pots
         } = table_state,
         [
           seat_lowest_all_in
           | other_all_in_seats_current_round
         ]
       ) do
    side_pot_value = pot_value + get_value_of_side_pot(seat_map, seat_lowest_all_in)
    pots = reset_active_pot_to_zero(pots)
    pots = add_seat_to_all_side_pots(pots, seat_lowest_all_in)
    pots = pots ++ [%{seats: [:all_active, seat_lowest_all_in], pot_value: side_pot_value}]
    seat_map = subtract_lowest_all_in_bet(seat_map, seat_lowest_all_in)
    table_state = %{table_state | seat_map: seat_map, pots: pots}
    create_side_pots(table_state, other_all_in_seats_current_round)
  end

  defp return_excess_bet(%{seat_map: seat_map, bet_to_call: bet_to_call} = table_state) do
    seat_map =
      seat_map
      |> Stream.map(fn {seat, player} ->
        excess_bet = max(player.chips_to_pot_current_bet_round - bet_to_call, 0)

        player = %{
          player
          | chips_to_pot_current_bet_round: player.chips_to_pot_current_bet_round - excess_bet,
            chip_count: player.chip_count + excess_bet
        }

        {seat, player}
      end)
      |> Enum.into(%{})

    %{table_state | seat_map: seat_map}
  end

  defp get_all_in_seats_current_round(seat_map) do
    seat_map
    |> filter_all_in_this_bet_round()
    |> sort_lowest_chips_in_pot()
    |> get_seats()
  end

  defp reset_active_pot_to_zero([_active_pot | sidepots]) do
    [%{seats: [:all_active], pot_value: 0}] ++ sidepots
  end

  defp add_seat_to_all_side_pots([active_pot | side_pots], seat) do
    side_pots =
      side_pots
      |> Enum.map(fn side_pot ->
        %{side_pot | seats: side_pot.seats ++ [seat]}
      end)

    [active_pot] ++ side_pots
  end

  defp add_seat_to_all_side_pots(pots, seat) do
    pots
  end

  defp sort_lowest_chips_in_pot(seat_map) do
    Enum.sort(seat_map, fn {_, player_a}, {_, player_b} ->
      player_b.chips_to_pot_current_bet_round >= player_a.chips_to_pot_current_bet_round
    end)
  end

  defp filter_all_in_this_bet_round(seat_map) do
    seat_map
    |> Enum.filter(fn {seat, player} ->
      player.status == :all_in and player.chips_to_pot_current_bet_round > 0
    end)
  end

  defp get_seats(seat_map) do
    seat_map
    |> Enum.map(fn {seat, _player} -> seat end)
  end

  defp get_value_of_side_pot(seat_map, seat_lowest_all_in) do
    lowest_all_in_bet = seat_map[seat_lowest_all_in].chips_to_pot_current_bet_round

    seat_map
    |> Enum.reduce(0, fn {seat, player}, side_pot_value ->
      side_pot_value + min(player.chips_to_pot_current_bet_round, lowest_all_in_bet)
    end)
  end

  defp subtract_lowest_all_in_bet(seat_map, seat_lowest_all_in) do
    lowest_all_in_bet = seat_map[seat_lowest_all_in].chips_to_pot_current_bet_round

    seat_map =
      seat_map
      |> Stream.map(fn {seat, player} ->
        player = %{
          player
          | chips_to_pot_current_bet_round:
              player.chips_to_pot_current_bet_round -
                min(player.chips_to_pot_current_bet_round, lowest_all_in_bet)
        }

        {seat, player}
      end)
      |> Enum.into(%{})
  end
end

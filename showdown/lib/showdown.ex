defmodule Showdown do
  def mark_hands_and_pot_winners(
        %{
          status: :showdown,
          community_cards:
            [_board_card_1, _board_card_2, _board_card_3, _board_card_4, _board_card_5] = board
        } = table_state
      ) do
    table_state
    |> Showdown.get_showdown_players_rank_hand()
    |> Showdown.get_pot_winners()
  end

  def get_pot_winners(
        %{
          seat_map: seat_map,
          status: :showdown,
          community_cards:
            [_board_card_1, _board_card_2, _board_card_3, _board_card_4, _board_card_5] = board,
          pots: pots
        } = table_state
      ) do
    active_seats_list = get_active_seats_list(seat_map)

    pots =
      pots
      |> Enum.map(fn pot ->
        pot_winners =
          pot
          |> get_pot_seat_list(active_seats_list)
          |> get_winning_players_in_pot(seat_map)

        %{pot | winners: pot_winners}
      end)

    %{table_state | pots: pots}
  end

  def get_showdown_players_rank_hand(
        %{
          seat_map: seat_map,
          community_cards:
            [_board_card_1, _board_card_2, _board_card_3, _board_card_4, _board_card_5] =
              community_cards
        } = table_state
      ) do
    seat_map =
      seat_map
      |> Enum.map(fn {seat, player} ->
        is_active_or_all_in? = player.status in [:active, :all_in]
        hand_rank_at_showdown = get_rank_hand(player.cards, community_cards, is_active_or_all_in?)
        player = %{player | hand_rank_at_showdown: hand_rank_at_showdown}
        {seat, player}
      end)
      |> Enum.into(%{})

    %{table_state | seat_map: seat_map}
  end

  def get_rank_hand(hole_cards, community_cards, true = _is_active_or_all_in?) do
    RankHand.get_rank_hole_board(hole_cards, community_cards)
  end

  def get_rank_hand(_hole_cards, _community_cards, false = _is_active_or_all_in?) do
    nil
  end

  def get_pot_seat_list(pot, active_seats_list) do
    [:all_active | all_in_pot_seats] = pot.seats
    pot_seats_list = active_seats_list ++ all_in_pot_seats
  end

  def get_winning_players_in_pot(pot_seats_list, seat_map) do
    pot_seats_list
    |> get_best_hand(seat_map)
    |> get_winning_seats(seat_map)
  end

  def get_best_hand(pot_seats_list, seat_map) do
    pot_seats_list
    |> Enum.map(fn seat ->
      seat_map[seat].hand_rank_at_showdown
    end)
    |> Enum.max_by(fn rank -> {rank.main_rank, rank.tie_breakers} end)
  end

  def get_winning_seats(best_hand, seat_map) do
    seat_map
    |> Enum.filter(fn {seat, player} ->
      player.hand_rank_at_showdown == best_hand
    end)
    |> Enum.map(fn {seat, _player} -> seat end)
  end

  def get_best_all_active_hand(
        %{
          seat_map: seat_map,
          status: :showdown,
          community_cards:
            [_board_card_1, _board_card_2, _board_card_3, _board_card_4, _board_card_5] = board
        } = table_state
      ) do
    seat_map
    |> filter_active_players()
    |> get_seat_hand_map(board)
    |> Enum.max_by(fn {seat, rank} -> {rank.main_rank, rank.tie_breakers} end)
  end

  defp filter_active_players(seat_map) do
    seat_map
    |> Enum.filter(fn {_seat, player} ->
      player.status == :active
    end)

    # |> Enum.into(%{})
  end

  defp get_seat_hand_map(seat_map, board) do
    seat_map
    |> Enum.map(fn {seat, player} ->
      {seat, RankHand.get_rank_hole_board(player.cards, board)}
    end)
    |> Enum.into(%{})
  end

  defp get_active_seats_list(seat_map) do
    IO.inspect(
      seat_map
      |> filter_active_players()
      |> get_seats()
    )
  end

  defp get_seats([]) do
    []
  end

  defp get_seats(seat_map) do
    seat_map
    |> Enum.map(fn {seat, _player} -> seat end)
  end
end

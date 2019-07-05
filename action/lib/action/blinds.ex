defmodule Action.Blinds do
  alias Action.Helpers

  def post_blinds(
        %{
          status: :posting_blinds,
          seat_map: seat_map,
          sb_seat: sb_seat,
          bb_seat: bb_seat,
          pre_action_min_bet: pre_action_min_bet,
          bet_to_call: bet_to_call
        } = table_state
      ) do
    sb_player =
      seat_map[sb_seat]
      |> Player.commit_chips_to_pot(round(pre_action_min_bet / 2))

    bb_player =
      seat_map[bb_seat]
      |> Player.commit_chips_to_pot(pre_action_min_bet)

    seat_map =
      seat_map
      |> Map.put(sb_seat, sb_player)
      |> Map.put(bb_seat, bb_player)

    %{
      table_state
      | seat_map: seat_map,
        bet_to_call: pre_action_min_bet + bet_to_call
    }
    |> Helpers.check_end_hand()
  end

  def post_blinds(table_state) do
    IO.puts("Not in blind posting state")
    table_state
  end
end

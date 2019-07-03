defmodule Action.Blinds do
  def post_blinds(
        %{
          status: :posting_blinds_antes,
          seat_map: seat_map,
          sb_seat: sb_seat,
          bb_seat: bb_seat,
          pre_action_min_bet: pre_action_min_bet,
          bet_to_call: bet_to_call
        } = table_state
      ) do
    sb_player =
      seat_map[sb_seat]
      |> Player.commit_chips_to_pot(pre_action_min_bet / 2)

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
        bet_to_call: pre_action_min_bet + bet_to_call,
        status: :action_opened
    }
  end
end

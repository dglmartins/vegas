defmodule Action.Helpers do
  @seat_with_action_accepted_status [:active]
  def check_end_action_after_check_call(
        %{seat_with_action: seat, last_to_act: seat} = table_state
      ) do
    check_end_hand(table_state)
  end

  def check_end_action_after_check_call(
        %{seat_with_action: seat, seat_map: seat_map} = table_state
      ) do
    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    %{table_state | seat_with_action: seat_with_action}
  end

  def check_end_action_after_fold(%{seat_with_action: seat, last_to_act: seat} = table_state) do
    check_end_hand(table_state)
  end

  def check_end_action_after_fold(%{seat_with_action: seat, seat_map: seat_map} = table_state) do
    seat_with_action =
      SeatHelpers.get_next_taken_seat(seat, seat_map, @seat_with_action_accepted_status)

    number_of_active_players =
      seat_map
      |> Enum.filter(fn {_seat, player} -> player.status == :active end)
      |> Enum.count()

    number_of_all_in_players =
      seat_map
      |> Enum.filter(fn {_seat, player} -> player.status == :all_in end)
      |> Enum.count()

    %{table_state | seat_with_action: seat_with_action}
    |> check_end_hand_after_fold_not_last_to_act(
      number_of_active_players,
      number_of_all_in_players
    )
  end

  def check_end_action_after_raise(%{seat_with_action: :no_other_seats} = table_state) do
    check_end_hand(table_state)
  end

  def check_end_action_after_raise(table_state) do
    table_state
  end

  def check_end_hand_after_fold_not_last_to_act(
        table_state,
        number_of_active_players,
        number_of_all_in_players
      )
      when number_of_active_players == 1 and number_of_all_in_players == 0 do
    %{
      table_state
      | status: :distributing_chips
    }
  end

  def check_end_hand_after_fold_not_last_to_act(
        table_state,
        _number_of_active_players,
        _number_of_all_in_players
      ) do
    table_state
  end

  def check_end_hand(%{seat_map: seat_map} = table_state) do
    number_of_active_players =
      seat_map
      |> Enum.filter(fn {_seat, player} -> player.status == :active end)
      |> Enum.count()

    number_of_all_in_players =
      seat_map
      |> Enum.filter(fn {_seat, player} -> player.status == :all_in end)
      |> Enum.count()

    check_end_hand(
      table_state,
      number_of_active_players,
      number_of_all_in_players
    )
  end

  def check_end_hand(
        table_state,
        number_of_active_players,
        number_of_all_in_players
      )
      when number_of_active_players == 0 and number_of_all_in_players == 1 do
    %{
      table_state
      | status: :distributing_chips
    }
  end

  def check_end_hand(
        table_state,
        number_of_active_players,
        number_of_all_in_players
      )
      when number_of_active_players <= 1 and number_of_all_in_players > 0 do
    %{
      table_state
      | status: :deal_to_showdown
    }
  end

  def check_end_hand(
        table_state,
        number_of_active_players,
        number_of_all_in_players
      )
      when number_of_active_players <= 1 and number_of_all_in_players == 0 do
    %{
      table_state
      | status: :distributing_chips
    }
  end

  def check_end_hand(
        %{status: :posting_antes} = table_state,
        _number_of_active_players,
        _number_of_all_in_players
      ) do
    %{
      table_state
      | status: :posting_blinds
    }
  end

  def check_end_hand(
        %{status: :posting_blinds} = table_state,
        _number_of_active_players,
        _number_of_all_in_players
      ) do
    %{
      table_state
      | status: :action_opened
    }
  end

  def check_end_hand(
        %{seat_with_action: seat, last_to_act: seat, dealer_seat: dealer_seat, seat_map: seat_map} =
          table_state,
        _number_of_active_players,
        _number_of_all_in_players
      ) do
    seat_with_action =
      SeatHelpers.get_next_taken_seat(dealer_seat, seat_map, @seat_with_action_accepted_status)

    %{table_state | status: :action_round_ended, seat_with_action: seat_with_action}
  end

  def check_end_hand(
        table_state,
        _number_of_active_players,
        _number_of_all_in_players
      ) do
    table_state
  end
end

defmodule NewHandTest do
  use ExUnit.Case
  doctest Table.Dealer.NewHand

  alias Table.{State, Dealer}

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "starts a nl_holdem hand" do
    hand_id = generate_hand_id()

    table_state = State.new(@min_bet, @ante, @game_type)

    player = Player.new("Danilo", 200)
    player_two = Player.new("Paula", 200)

    player_three = Player.new("Michel", 200)

    player_four = Player.new("Renato", 200)

    {_status, table_state} = State.join_table(table_state, player, 1)
    {_status, table_state} = State.join_table(table_state, player_two, 3)
    {_status, table_state} = State.join_table(table_state, player_three, 7)
    {_status, table_state} = State.join_table(table_state, player_four, 9)

    table_state = State.move_dealer_to_seat(table_state, 3)

    table_state = Dealer.NewHand.start_hand(table_state, hand_id)

    danilo_cards = table_state.seat_map[1].cards

    assert [table_state.pre_action_min_bet, table_state.ante, table_state.dealer_seat] == [
             10,
             0,
             3
           ]

    assert Enum.count(table_state.seat_map) == 4

    assert table_state.seat_map[1] == %Player{
             cards: danilo_cards,
             chip_count: 200,
             name: "Danilo",
             status: :active,
             chips_commited_to_pot: 0
           }

    assert table_state.sb_seat == 7
    assert table_state.bb_seat == 9
    assert table_state.last_to_act == 9
    assert table_state.seat_with_action == 1
    assert table_state.full_bet_to_call == 10
    # assert table_state.status == :dealing_hole_cards
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

defmodule StateTest do
  use ExUnit.Case
  doctest Table.State

  alias Table.{State}

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "creates a table given a table id" do
    table = State.new(@min_bet, @ante, @game_type)

    assert table.status == :waiting
    assert table.pre_action_min_bet == 10
    assert table.game_type == :nl_holdem
    assert table.ante == 0
    assert table.pots == [%Pot{seats: [:all_active], pot_value: 0, winners: []}]

    assert Enum.count(table.seat_map) == 0

    for seat <- 1..10 do
      assert table.seat_map[seat] == nil
    end
  end

  test "player joins cannot join taken seat" do
    table = State.new(@min_bet, @ante, @game_type)
    player = Player.new("Danilo", 200)

    {status, table} = State.join_table(table, player, 2)

    assert status == :ok
    assert table.seat_map[2] == player

    player_two = Player.new("Paula", 200)

    {status, table} = State.join_table(table, player_two, 2)

    assert status == :seat_taken
    assert table.seat_map[2] == player
  end

  test "player leaves" do
    table = State.new(@min_bet, @ante, @game_type)
    player = Player.new("Danilo", 200)

    {status, table} = State.join_table(table, player, 2)

    assert status == :ok
    assert table.seat_map[2] == player

    table = State.leave_table(table, 2)

    assert table.seat_map[2] == nil
  end
end

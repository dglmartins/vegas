defmodule StateTest do
  use ExUnit.Case
  doctest Player.State

  alias Player.State

  test "creates a player" do
    player = State.new("Danilo", 200)
    assert player == %State{name: "Danilo", chip_count_off_tables: 200}
  end

  test "joins a table" do
    table_id = "test_table"

    player = State.new("Danilo", 200) |> State.join_table(table_id, 100)

    assert player.status_in_tables[table_id] == :active
    assert player.chip_count_off_tables == 100
    assert player.chip_count_in_tables[table_id] == 100
  end

  test "does not join if arealdy joined" do
    table_id = "test_table"

    player =
      State.new("Danilo", 200)
      |> State.join_table(table_id, 200)
      |> State.join_table(table_id, 200)

    assert player.status_in_tables[table_id] == :active
    assert Enum.count(player.status_in_tables) == 1
    assert player.chip_count_off_tables == 0
  end

  test "joins with max chips if not enough chips" do
    table_id = "test_table"

    player =
      State.new("Danilo", 200)
      |> State.join_table(table_id, 300)

    assert player.status_in_tables[table_id] == :active
    assert player.chip_count_off_tables == 0
    assert player.chip_count_in_tables[table_id] == 200
  end

  test "joins table and changes player status" do
    table_id = "test_table"

    # tries to change status on table not joined does not work
    player =
      State.new("Danilo", 200) |> State.change_player_status_in_table(:sitting_out, table_id)

    assert player.status_in_tables == %{}

    # joins table with :active status
    player = player |> State.join_table(table_id, 200)

    assert player.status_in_tables[table_id] == :active
    assert player.cards_in_tables[table_id] == []

    # changes status of table already joined
    player = player |> State.change_player_status_in_table(:sitting_out, table_id)

    assert player.status_in_tables[table_id] == :sitting_out

    # does not change status of a new table, keeps existing table status
    new_table_id = "new_test_table"

    player = player |> State.change_player_status_in_table(:active, new_table_id)
    assert player.status_in_tables[table_id] == :sitting_out
    assert Map.has_key?(player.status_in_tables, new_table_id) == false

    # does not change status to unnaccepted status

    player = player |> State.change_player_status_in_table(:foo_bar, table_id)
    assert player.status_in_tables[table_id] == :sitting_out
  end

  test "deals hole cards to players" do
    table_id = "test_table"

    card = Card.new(2, :spades)

    player =
      State.new("Danilo", 200)
      |> State.join_table(table_id, 200)
      |> State.deal_hole_card(table_id, card)

    assert player.cards_in_tables[table_id] == [card]
  end
end

defmodule PlayerTest do
  use ExUnit.Case
  doctest Player

  test "creates a player" do
    player = Player.new("Danilo", 200)
    assert player == %Player{name: "Danilo", chip_count_off_tables: 200}
  end

  test "joins a table" do
    table_id = "test_table"

    player = Player.new("Danilo", 200) |> Player.join_table(table_id)

    assert player.status_in_tables[table_id] == :active
  end

  test "joins table and changes player status" do
    table_id = "test_table"

    # tries to change status on table not joined does not work
    player =
      Player.new("Danilo", 200) |> Player.change_player_status_in_table(:sitting_out, table_id)

    assert player.status_in_tables == %{}

    # joins table with :active status
    player = player |> Player.join_table(table_id)

    assert player.status_in_tables[table_id] == :active

    # changes status of table already joined
    player = player |> Player.change_player_status_in_table(:sitting_out, table_id)

    assert player.status_in_tables[table_id] == :sitting_out

    # does not change status of a new table, keeps existing table status
    new_table_id = "new_test_table"

    player = player |> Player.change_player_status_in_table(:active, new_table_id)
    assert player.status_in_tables[table_id] == :sitting_out
    assert Map.has_key?(player.status_in_tables, new_table_id) == false

    # does not change status to unnaccepted status

    player = player |> Player.change_player_status_in_table(:foo_bar, table_id)
    assert player.status_in_tables[table_id] == :sitting_out

    # player = Player.change_player_status(player, :unnacepted_status)
    # assert player == %Player{name: "Danilo", chip_count: 200, status: :sitting_out}
    #
    # player = Player.change_player_status(player, :active_in_table)
    # assert player == %Player{name: "Danilo", chip_count: 200, status: :active_in_table}
  end
end

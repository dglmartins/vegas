defmodule TableTest do
  use ExUnit.Case
  doctest Table

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "new spawns a table server process and is unique if created again" do
    table_id = generate_table_id()

    assert {:ok, _pid} = Table.new(table_id, @min_bet, @ante, @game_type)
    assert {:error, {:already_started, _pid}} = Table.new(table_id, @min_bet, @ante, @game_type)
  end

  describe "table_pid" do
    test "returns a PID if it has been registered" do
      table_id = generate_table_id()

      {:ok, pid} = Table.new(table_id, @min_bet, @ante, @game_type)
      assert ^pid = Table.table_pid(table_id)
    end

    test "returns nil if the deck does not exist" do
      refute Table.table_pid("nonexistent-deck")
    end
  end

  test "gets table_ids" do
    table_id_one = generate_table_id()
    table_id_two = generate_table_id()

    {:ok, _pid} = Table.new(table_id_one, @min_bet, @ante, @game_type)
    {:ok, _pid} = Table.new(table_id_two, @min_bet, @ante, @game_type)

    assert table_id_one in Table.table_ids()
    assert table_id_two in Table.table_ids()
  end

  test "stops table" do
    table_id_one = generate_table_id()
    table_id_two = generate_table_id()

    {:ok, _pid} = Table.new(table_id_one, @min_bet, @ante, @game_type)
    {:ok, _pid} = Table.new(table_id_two, @min_bet, @ante, @game_type)

    :ok = Table.stop_table(table_id_one)

    refute table_id_one in Table.table_ids()
    assert table_id_two in Table.table_ids()
  end

  defp generate_table_id() do
    "table-#{:rand.uniform(1_000_000)}"
  end
end

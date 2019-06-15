defmodule TableTest do
  use ExUnit.Case
  doctest Table

  alias Table.TableServer

  @min_bet 10
  @ante 0

  test "new spawns a table server process and is unique if created again" do
    table_id = generate_table_id()

    assert {:ok, _pid} = Table.new(table_id, @min_bet, @ante)
    assert {:error, {:already_started, _pid}} = Table.new(table_id, @min_bet, @ante)
  end

  test "deal_card deals a card" do
    table_id = generate_table_id()

    {:ok, _pid} = Table.new(table_id, @min_bet, @ante)

    card = Table.deal_card(table_id)

    assert card.rank in 2..14
    assert card.suit in [:hearts, :clubs, :diamonds, :spades]
    assert TableServer.count_deck(table_id) == 51
  end

  describe "table_pid" do
    test "returns a PID if it has been registered" do
      table_id = generate_table_id()

      {:ok, pid} = Table.new(table_id, @min_bet, @ante)
      assert ^pid = Table.table_pid(table_id)
    end

    test "returns nil if the deck does not exist" do
      refute Table.table_pid("nonexistent-deck")
    end
  end

  test "reshuffles a deck" do
    table_id = generate_table_id()

    {:ok, _pid} = Table.new(table_id, @min_bet, @ante)

    _card = Table.deal_card(table_id)

    assert TableServer.count_deck(table_id) == 51

    Table.reshuffle(table_id)

    assert TableServer.count_deck(table_id) == 52
  end

  test "gets deck_ids" do
    table_id_one = generate_table_id()
    table_id_two = generate_table_id()

    {:ok, _pid} = Table.new(table_id_one, @min_bet, @ante)
    {:ok, _pid} = Table.new(table_id_two, @min_bet, @ante)

    _card_deck_one = Table.deal_card(table_id_one)
    _card_deck_two = Table.deal_card(table_id_two)

    assert TableServer.count_deck(table_id_one) == 51
    assert TableServer.count_deck(table_id_two) == 51

    assert table_id_one in Table.table_ids()
    assert table_id_two in Table.table_ids()
  end

  test "stops table" do
    table_id_one = generate_table_id()
    table_id_two = generate_table_id()

    {:ok, _pid} = Table.new(table_id_one, @min_bet, @ante)
    {:ok, _pid} = Table.new(table_id_two, @min_bet, @ante)

    :ok = Table.stop_table(table_id_one)

    refute table_id_one in Table.table_ids()
    assert table_id_two in Table.table_ids()
  end

  defp generate_table_id() do
    "table-#{:rand.uniform(1_000_000)}"
  end
end

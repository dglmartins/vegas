defmodule TableServerTest do
  use ExUnit.Case
  doctest Table.TableServer

  alias Table.{TableServer, Deck, State}

  test "spawning a deck server process" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id)
  end

  test "a table process is registered under a unique table_id and cannot be restarted" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id)

    assert {:error, {:already_started, _pid}} = TableServer.start_link(table_id)
  end

  test "table server deals a card" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id)

    card = TableServer.deal_card(table_id)

    assert card.rank in 2..14
    assert card.suit in [:hearts, :clubs, :diamonds, :spades]
    assert TableServer.count_deck(table_id) == 51
  end

  test "reshuffles a deck" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id)

    card = TableServer.deal_card(table_id)

    assert TableServer.count_deck(table_id) == 51

    TableServer.reshuffle(table_id)

    assert TableServer.count_deck(table_id) == 52
  end

  test "deck is empty after dealing 52 cards" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id)

    for _deal <- 1..52 do
      TableServer.deal_card(table_id)
    end

    card = TableServer.deal_card(table_id)

    assert card.rank == nil
    assert card.suit == nil
    assert TableServer.count_deck(table_id) == 0
  end

  test "gets dealer seat and moves dealer seat" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id)

    dealer_seat_index = TableServer.get_dealer_seat_index(table_id)

    assert dealer_seat_index == nil

    {:ok, new_seat_index} = TableServer.move_dealer_to_seat({table_id, 3})

    assert new_seat_index == 3

    dealer_seat_index = TableServer.get_dealer_seat_index(table_id)

    assert new_seat_index == dealer_seat_index
  end

  describe "ets" do
    test "stores initial table state in ETS when started" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id)

      assert [{^table_id, %State{deck: deck}}] = :ets.lookup(:tables_table, table_id)

      [first_card | _rest_of_deck] = deck

      assert first_card == TableServer.deal_card(table_id)
    end

    test "gets the table initial state from ETS if previously stored" do
      table_id = generate_table_id()

      state = State.new()

      [_dealt_card | rest_of_deck] = state.deck

      new_state = %{state | deck: rest_of_deck}
      :ets.insert(:tables_table, {table_id, new_state})

      {:ok, _pid} = TableServer.start_link(table_id)

      assert TableServer.count_deck(table_id) == 51
    end

    test "updates table state in ETS when card is dealt" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id)

      card = TableServer.deal_card(table_id)

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(ets_table.deck) == 51
    end

    test "updates table state in ETS when deck is shuffled" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id)

      card = TableServer.deal_card(table_id)

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(ets_table.deck) == 51

      TableServer.reshuffle(table_id)

      [{^table_id, reshuffled_ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(reshuffled_ets_table.deck) == 52
    end
  end

  describe "table_pid" do
    test "returns a PID if it has been registered" do
      table_id = generate_table_id()

      {:ok, pid} = TableServer.start_link(table_id)
      assert ^pid = TableServer.table_pid(table_id)
    end

    test "returns nil if the table does not exist" do
      refute TableServer.table_pid("nonexistent-deck")
    end
  end

  defp generate_table_id() do
    "table-#{:rand.uniform(1_000_000)}"
  end
end

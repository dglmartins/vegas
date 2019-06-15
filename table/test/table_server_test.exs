defmodule TableServerTest do
  use ExUnit.Case
  doctest Table.TableServer

  alias Table.{TableServer, State, Player}

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "spawning a deck server process" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  end

  test "a table process is registered under a unique table_id and cannot be restarted" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    assert {:error, {:already_started, _pid}} =
             TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  end

  test "table server deals a card" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    card = TableServer.deal_card(table_id)

    assert card.rank in 2..14
    assert card.suit in [:hearts, :clubs, :diamonds, :spades]
    assert TableServer.count_deck(table_id) == 51
  end

  test "reshuffles a deck" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    _card = TableServer.deal_card(table_id)

    assert TableServer.count_deck(table_id) == 51

    TableServer.reshuffle(table_id)

    assert TableServer.count_deck(table_id) == 52
  end

  test "deck is empty after dealing 52 cards" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    for _deal <- 1..52 do
      TableServer.deal_card(table_id)
    end

    card = TableServer.deal_card(table_id)

    assert card.rank == nil
    assert card.suit == nil
    assert TableServer.count_deck(table_id) == 0
  end

  test "gets dealer seat, moves dealer seat, moves dealer to left" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    dealer_seat = TableServer.get_dealer_seat(table_id)

    assert dealer_seat == nil

    {:ok, new_seat} = TableServer.move_dealer_to_seat({table_id, 9})

    assert new_seat == 9
    assert new_seat == TableServer.get_dealer_seat(table_id)

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == 10
    assert new_seat == TableServer.get_dealer_seat(table_id)

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == 1
    assert new_seat == TableServer.get_dealer_seat(table_id)
  end

  test "joins and leaves table, gets seat map" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    player = Player.new("Danilo", 200)
    player_two = Player.new("Paula", 200)

    status = TableServer.join_table({table_id, player, 2})
    status_two = TableServer.join_table({table_id, player_two, 2})

    assert status == :ok
    assert status_two == :seat_taken

    seat_map = TableServer.get_seat_map(table_id)

    assert seat_map[2] == player

    :ok = TableServer.leave_table({table_id, 2})

    seat_map = TableServer.get_seat_map(table_id)

    assert seat_map[2] == :empty_seat

    status_two = TableServer.join_table({table_id, player_two, 2})

    assert status_two == :ok

    seat_map = TableServer.get_seat_map(table_id)

    assert seat_map[2] == player_two
  end

  describe "ets" do
    test "stores initial table state in ETS when started" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert [{^table_id, %State{deck: deck}}] = :ets.lookup(:tables_table, table_id)

      [first_card | _rest_of_deck] = deck

      assert first_card == TableServer.deal_card(table_id)
    end

    test "gets the table initial state from ETS if previously stored" do
      table_id = generate_table_id()

      state = State.new(@min_bet, @ante, @game_type)

      [_dealt_card | rest_of_deck] = state.deck

      new_state = %{state | deck: rest_of_deck}
      :ets.insert(:tables_table, {table_id, new_state})

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert TableServer.count_deck(table_id) == 51
    end

    test "updates table state in ETS when card is dealt" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      _card = TableServer.deal_card(table_id)

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(ets_table.deck) == 51
    end

    test "updates table state in ETS when deck is shuffled" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      _card = TableServer.deal_card(table_id)

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(ets_table.deck) == 51

      TableServer.reshuffle(table_id)

      [{^table_id, reshuffled_ets_table}] = :ets.lookup(:tables_table, table_id)

      assert Enum.count(reshuffled_ets_table.deck) == 52
    end

    test "updates table state in ETS when dealer is moved to new seat or to the left" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 3})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == 3

      {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == 4
    end

    test "updates table state in ETS when players join and leave" do
      table_id = generate_table_id()

      player = Player.new("Danilo", 200)
      player_two = Player.new("Paula", 200)

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      _status = TableServer.join_table({table_id, player, 2})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.seat_map[2] == player

      :ok = TableServer.leave_table({table_id, 2})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.seat_map[2] == :empty_seat
    end
  end

  describe "table_pid" do
    test "returns a PID if it has been registered" do
      table_id = generate_table_id()

      {:ok, pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
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

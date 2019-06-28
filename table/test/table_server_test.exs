defmodule TableServerTest do
  use ExUnit.Case
  doctest Table.TableServer

  alias Table.{TableServer, State}

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "spawning a table server process" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  end

  test "a table process is registered under a unique table_id and cannot be restarted" do
    table_id = generate_table_id()

    assert {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    assert {:error, {:already_started, _pid}} =
             TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  end

  test "gets dealer seat, moves dealer seat, moves dealer to left, does not move dealer if no one sitting" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    dealer_seat = TableServer.get_dealer_seat(table_id)

    assert dealer_seat == nil

    {:ok, new_seat} = TableServer.move_dealer_to_seat({table_id, 9})

    assert new_seat == nil
    assert new_seat == TableServer.get_dealer_seat(table_id)

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == nil
    assert new_seat == TableServer.get_dealer_seat(table_id)

    player = Player.new("Danilo", 200)

    _status = TableServer.join_table({table_id, player, 2})

    {:ok, new_seat} = TableServer.move_dealer_to_seat({table_id, 2})

    assert new_seat == 2

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == 2

    player_two = Player.new("Danilo", 200)

    _status_two = TableServer.join_table({table_id, player_two, 7})

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == 7

    {:ok, new_seat} = TableServer.move_dealer_to_left(table_id)

    assert new_seat == 2
  end

  test "gets game type, gets min bet, gets ante" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    game_type = TableServer.get_game_type(table_id)
    {pre_action_min_bet, ante} = TableServer.get_pre_action_min_bet_ante(table_id)

    assert game_type == @game_type
    assert pre_action_min_bet == @min_bet
    assert ante == @ante
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

    assert seat_map[2] == nil

    status_two = TableServer.join_table({table_id, player_two, 2})

    assert status_two == :ok

    seat_map = TableServer.get_seat_map(table_id)

    assert seat_map[2] == player_two
  end

  describe "ets" do
    test "stores initial table state in ETS when started" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert [{^table_id, %State{}}] = :ets.lookup(:tables_table, table_id)
    end

    test "gets the table initial state from ETS if previously stored" do
      table_id = generate_table_id()

      state = State.new(@min_bet, @ante, @game_type)

      new_state = %{state | game_type: :horse}
      :ets.insert(:tables_table, {table_id, new_state})

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert TableServer.get_game_type(table_id) == :horse
    end

    test "updates table state in ETS when dealer is moved to new seat or to the left" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 3})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == nil

      {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == nil

      player = Player.new("Danilo", 200)

      player_two = Player.new("Paula", 200)

      _status = TableServer.join_table({table_id, player, 2})
      _status_two = TableServer.join_table({table_id, player_two, 7})

      {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 2})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == 2

      {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == 7

      {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.dealer_seat == 2
    end

    test "updates table state in ETS when players join and leave" do
      table_id = generate_table_id()

      player = Player.new("Danilo", 200)

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      _status = TableServer.join_table({table_id, player, 2})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.seat_map[2] == player

      :ok = TableServer.leave_table({table_id, 2})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.seat_map[2] == nil
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

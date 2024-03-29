defmodule TableServerTest do
  use ExUnit.Case
  doctest Table.TableServer

  alias Table.{TableServer, State}

  @min_bet 20
  @ante 2
  @game_type :nl_holdem
  @table_id "test_id"

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

  test "gets dealer seat" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    dealer_seat = TableServer.get_dealer_seat(table_id)

    assert dealer_seat == nil

    player = Player.new("Danilo", 200)

    _status = TableServer.join_table({table_id, player, 2})

    player_two = Player.new("Paula", 200)

    _status_two = TableServer.join_table({table_id, player_two, 7})

    dealer_seat = TableServer.get_dealer_seat(table_id)

    assert dealer_seat == 7
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

  test "2 players join, table starts hand, deals hole cards, posts antes, posts blinds" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    player = Player.new("Danilo", 200)

    player_two = Player.new("Paula", 200)

    status = TableServer.join_table({table_id, player, 2})
    tally = TableServer.get_tally(table_id)

    assert tally.status == :waiting
    status_two = TableServer.join_table({table_id, player_two, 3})
    tally = TableServer.get_tally(table_id)

    assert tally.status == :hand_to_start

    :timer.sleep(500)

    tally = IO.inspect(TableServer.get_tally(table_id))

    assert tally.status == :action_opened
    assert tally.seat_map[2].chip_count == 178
    assert tally.seat_map[3].chip_count == 188
    assert tally.seat_with_action == 3
    assert tally.dealer_seat == 3
  end

  test "2 players join, table starts hand, deals hole cards, posts antes, one player is all in -> status is :deal_to_showdown" do
    table_id = generate_table_id()

    {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

    player = Player.new("Danilo", 1)

    player_two = Player.new("Paula", 3)

    status = TableServer.join_table({table_id, player, 2})
    tally = TableServer.get_tally(table_id)

    assert tally.status == :waiting
    status_two = TableServer.join_table({table_id, player_two, 3})
    tally = TableServer.get_tally(table_id)

    assert tally.status == :hand_to_start

    :timer.sleep(500)

    tally = IO.inspect(TableServer.get_tally(table_id))

    assert tally.status == :deal_to_showdown
    assert tally.seat_map[2].chip_count == 0
    assert tally.seat_map[2].status == :all_in
    assert tally.seat_map[3].chip_count == 1
  end

  # test "does not start at hand with no dealer" do
  #   table_id = generate_table_id()
  #   hand_id = generate_hand_id()
  #
  #   {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  #
  #   player = Player.new("Danilo", 250)
  #   player_three = Player.new("Paula", 220)
  #   player_seven = Player.new("Michel", 180)
  #
  #   TableServer.join_table({table_id, player, 1})
  #   TableServer.join_table({table_id, player_three, 3})
  #   TableServer.join_table({table_id, player_seven, 7})
  #
  #   :ok = TableServer.start_hand(table_id)
  #
  #   seat_map = TableServer.get_seat_map(table_id)
  #
  #   assert Enum.count(seat_map[1].cards) == 0
  #   assert Enum.count(seat_map[3].cards) == 0
  #   assert Enum.count(seat_map[7].cards) == 0
  # end

  # test "does not start at hand with not enough players" do
  #   table_id = generate_table_id()
  #   hand_id = generate_hand_id()
  #
  #   {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  #
  #   player = Player.new("Danilo", 250)
  #
  #   TableServer.join_table({table_id, player, 1})
  #   {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 1})
  #
  #   :ok = TableServer.start_hand(table_id)
  #
  #   seat_map = TableServer.get_seat_map(table_id)
  #
  #   assert Enum.count(seat_map[1].cards) == 0
  # end

  # test "starts at hand with at least two players and a dealer" do
  #   table_id = generate_table_id()
  #   hand_id = generate_hand_id()
  #
  #   {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
  #
  #   player = Player.new("Danilo", 250)
  #   player_three = Player.new("Paula", 220)
  #
  #   TableServer.join_table({table_id, player, 1})
  #   TableServer.join_table({table_id, player_three, 3})
  #
  #   {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 3})
  #
  #   :ok = TableServer.start_hand(table_id)
  #
  #   seat_map = TableServer.get_seat_map(table_id)
  #
  #   assert Enum.count(seat_map[1].cards) == 0
  #   assert Enum.count(seat_map[3].cards) == 0
  # end

  describe "ets" do
    test "stores initial table state in ETS when started" do
      table_id = generate_table_id()

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert [{^table_id, %State{}}] = :ets.lookup(:tables_table, table_id)
    end

    test "gets the table initial state from ETS if previously stored" do
      table_id = generate_table_id()

      state = State.new(@min_bet, @ante, @game_type, @table_id)

      new_state = %{state | game_type: :horse}
      :ets.insert(:tables_table, {table_id, new_state})

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      assert TableServer.get_game_type(table_id) == :horse
    end

    # test "updates table state in ETS when dealer is moved to new seat or to the left" do
    #   table_id = generate_table_id()
    #
    #   {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)
    #
    #   {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 3})
    #
    #   [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)
    #
    #   assert ets_table.dealer_seat == nil
    #
    #   {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
    #   [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)
    #
    #   assert ets_table.dealer_seat == nil
    #
    #   player = Player.new("Danilo", 200)
    #
    #   player_two = Player.new("Paula", 200)
    #
    #   _status = TableServer.join_table({table_id, player, 2})
    #   _status_two = TableServer.join_table({table_id, player_two, 7})
    #
    #   {:ok, _dealer_seat} = TableServer.move_dealer_to_seat({table_id, 2})
    #
    #   [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)
    #
    #   assert ets_table.dealer_seat == 2
    #
    #   {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
    #   [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)
    #
    #   assert ets_table.dealer_seat == 7
    #
    #   {:ok, _dealer_seat} = TableServer.move_dealer_to_left(table_id)
    #   [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)
    #
    #   assert ets_table.dealer_seat == 2
    # end

    test "updates table state in ETS when players join and leave" do
      table_id = generate_table_id()

      player = Player.new("Danilo", 200)
      player_two = Player.new("Paula", 200)

      {:ok, _pid} = TableServer.start_link(table_id, @min_bet, @ante, @game_type)

      _status = TableServer.join_table({table_id, player, 2})
      _status = TableServer.join_table({table_id, player_two, 3})

      [{^table_id, ets_table}] = :ets.lookup(:tables_table, table_id)

      assert ets_table.seat_map[2] == player
      assert ets_table.seat_map[3] == player_two
      assert ets_table.dealer_seat == 3

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

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

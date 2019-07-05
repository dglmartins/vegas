defmodule SeatSetupTest do
  use ExUnit.Case
  doctest HandSetup.SeatSetup

  alias HandSetup.SeatSetup

  @seat_map %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200)
  }

  @seat_map_two %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200)
  }

  @seat_map_three %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    9 => Player.new("Renato", 200),
    10 => Player.new("Rodrigo", 200)
  }

  @dealer_seat 3

  test "gets sb seat" do
    assert SeatSetup.get_sb_seat(@dealer_seat, @seat_map) == 7
    assert SeatSetup.get_sb_seat(@dealer_seat, @seat_map_two) == 3
    assert SeatSetup.get_sb_seat(@dealer_seat, @seat_map_three) == 9
  end

  test "gets bb seat" do
    assert SeatSetup.get_bb_seat(@dealer_seat, @seat_map) == 1
    assert SeatSetup.get_bb_seat(@dealer_seat, @seat_map_two) == 1
    assert SeatSetup.get_bb_seat(@dealer_seat, @seat_map_three) == 10
  end

  test "gets first_to_act first round" do
    player_one = %{@seat_map_three[1] | chip_count: 0, status: :all_in}

    seat_map_three = Map.put(@seat_map_three, 1, player_one)
    assert SeatSetup.get_first_to_act_first_round(@dealer_seat, @seat_map) == 3
    assert SeatSetup.get_first_to_act_first_round(@dealer_seat, @seat_map_two) == 3
    assert SeatSetup.get_first_to_act_first_round(@dealer_seat, @seat_map_three) == 1

    assert SeatSetup.get_first_to_act_first_round(@dealer_seat, seat_map_three) == 3
  end

  test "gets last_to_act first round" do
    player_ten = %{@seat_map_three[10] | chip_count: 0, status: :all_in}

    seat_map_three = Map.put(@seat_map_three, 10, player_ten)
    assert SeatSetup.get_last_to_act_first_round(@dealer_seat, @seat_map) == 1
    assert SeatSetup.get_last_to_act_first_round(@dealer_seat, @seat_map_two) == 1
    assert SeatSetup.get_last_to_act_first_round(@dealer_seat, @seat_map_three) == 10

    assert SeatSetup.get_last_to_act_first_round(@dealer_seat, seat_map_three) == 9
  end
end

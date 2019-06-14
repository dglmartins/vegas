defmodule StateTest do
  use ExUnit.Case
  doctest Table.State

  alias Table.State

  test "creates a table given a table id" do
    table = State.new()

    assert table.status == :waiting
    assert Enum.count(table.deck) == 52
    assert Enum.count(table.seat_list) == 10

    for index <- 0..9 do
      assert Enum.at(table.seat_list, index) == :empty_seat
    end
  end

  test "moves dealer seat, does not move if not integer or if index > 9" do
    table = State.new()
    assert table.dealer_seat_index == nil

    table =
      table
      |> State.move_dealer_to_seat(3)

    assert table.dealer_seat_index == 3

    table =
      table
      |> State.move_dealer_to_seat("not an integer")

    assert table.dealer_seat_index == 3

    table =
      table
      |> State.move_dealer_to_seat(10)

    assert table.dealer_seat_index == 3
  end

  test "moves dealer seat to left, moves to zero if current index is 9" do
    table = State.new()
    assert table.dealer_seat_index == nil

    table =
      table
      |> State.move_dealer_to_left()

    assert table.dealer_seat_index == nil

    table =
      table
      |> State.move_dealer_to_seat(8)

    assert table.dealer_seat_index == 8

    table =
      table
      |> State.move_dealer_to_left()

    assert table.dealer_seat_index == 9

    table =
      table
      |> State.move_dealer_to_left()

    assert table.dealer_seat_index == 0
  end
end

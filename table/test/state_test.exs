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
end

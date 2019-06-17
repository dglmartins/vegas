defmodule PlayerTest do
  use ExUnit.Case
  doctest Player

  test "creates a player" do
    player = Player.new("Danilo", 200)
    assert player == %Player{name: "Danilo", chip_count: 200, status: :active}
  end

  test "changes player status" do
    player = Player.new("Danilo", 200) |> Player.change_player_status(:sitting_out)
    assert player == %Player{name: "Danilo", chip_count: 200, status: :sitting_out}

    player = Player.change_player_status(player, :unnacepted_status)
    assert player == %Player{name: "Danilo", chip_count: 200, status: :sitting_out}

    player = Player.change_player_status(player, :active)
    assert player == %Player{name: "Danilo", chip_count: 200, status: :active}
  end
end

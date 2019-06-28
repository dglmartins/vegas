defmodule PlayerTest do
  use ExUnit.Case
  doctest Player

  test "creates a player" do
    player = Player.new("Danilo", 200)

    assert player == %Player{
             name: "Danilo",
             chip_count: 200,
             cards: [],
             status: :active,
             chips_commited_to_pot: 0
           }
  end

  test "bets to chips_commited_to_pot" do
    player =
      Player.new("Danilo", 200)
      |> Player.commit_chips_to_pot(100)

    assert player == %Player{
             name: "Danilo",
             chip_count: 100,
             cards: [],
             status: :active,
             chips_commited_to_pot: 100
           }

    player = player |> Player.commit_chips_to_pot(50)

    assert player == %Player{
             name: "Danilo",
             chip_count: 50,
             cards: [],
             status: :active,
             chips_commited_to_pot: 150
           }

    player = player |> Player.commit_chips_to_pot(200)

    assert player == %Player{
             name: "Danilo",
             chip_count: 0,
             cards: [],
             status: :all_in,
             chips_commited_to_pot: 200
           }
  end

  test "resets player adds chips won" do
    player =
      Player.new("Danilo", 200)
      |> Player.commit_chips_to_pot(300)
      |> Player.reset_player_add_chips(600)

    assert player == %Player{
             name: "Danilo",
             chip_count: 600,
             cards: [],
             status: :active,
             chips_commited_to_pot: 0
           }

    player =
      player
      |> Player.commit_chips_to_pot(100)
      |> Player.commit_chips_to_pot(100)
      |> Player.commit_chips_to_pot(100)
      |> Player.commit_chips_to_pot(300)
      |> Player.reset_player_add_chips(0)

    assert player == %Player{
             name: "Danilo",
             chip_count: 0,
             cards: [],
             status: :eliminated,
             chips_commited_to_pot: 0
           }
  end
end

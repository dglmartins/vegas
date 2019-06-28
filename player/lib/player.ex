defmodule Player do
  defstruct name: nil,
            chip_count: nil,
            cards: [],
            status: :active,
            chips_commited_to_pot: 0

  def new(name, chip_count) do
    %Player{name: name, chip_count: chip_count}
  end

  def add_to_chip_count(%Player{chip_count: chip_count} = player, chips) do
    %{player | chip_count: chip_count + chips}
  end

  def commit_chips_to_pot(%Player{status: :all_in} = player, _chips) do
    IO.puts("Player is already all in")
    player
  end

  def commit_chips_to_pot(%Player{chip_count: chip_count} = player, chips) do
    has_enough_chips? = chip_count >= chips
    commit_chips_to_pot(player, chips, has_enough_chips?)
  end

  def commit_chips_to_pot(
        %Player{chip_count: chip_count, chips_commited_to_pot: chips_commited_to_pot} = player,
        chips,
        true = _has_enough_chips?
      ) do
    %{
      player
      | chip_count: chip_count - chips,
        chips_commited_to_pot: chips_commited_to_pot + chips
    }
  end

  def commit_chips_to_pot(
        %Player{chip_count: chip_count, chips_commited_to_pot: chips_commited_to_pot} = player,
        _chips,
        false = _has_enough_chips?
      ) do
    %{
      player
      | chip_count: 0,
        chips_commited_to_pot: chips_commited_to_pot + chip_count,
        status: :all_in
    }
  end

  def reset_player_add_chips(%Player{chip_count: 0} = player, 0 = _chips_won) do
    %{player | status: :eliminated, chips_commited_to_pot: 0, cards: []}
  end

  def reset_player_add_chips(%Player{chip_count: chip_count} = player, chips_won) do
    %{
      player
      | status: :active,
        chip_count: chip_count + chips_won,
        chips_commited_to_pot: 0,
        cards: []
    }
  end
end

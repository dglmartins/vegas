defmodule Player.Chips do
  alias Player

  def add_to_chip_count(%Player{chip_count: chip_count} = player, chips) do
    %{player | chip_count: chip_count + chips}
  end

  def commit_chips_to_pot(%Player{status: :all_in} = player, _chips) do
    IO.puts("Player is already all in")
    player
  end

  def commit_chips_to_pot(%Player{chip_count: chip_count} = player, chips) do
    has_enough_chips? = chip_count > chips
    commit_chips_to_pot(player, chips, has_enough_chips?)
  end

  def commit_chips_to_pot(
        %Player{
          chip_count: chip_count,
          chips_to_pot_current_bet_round: chips_to_pot_current_bet_round
        } = player,
        chips,
        true = _has_enough_chips?
      ) do
    %{
      player
      | chip_count: chip_count - chips,
        chips_to_pot_current_bet_round: chips_to_pot_current_bet_round + chips
    }
  end

  def commit_chips_to_pot(
        %Player{
          chip_count: chip_count,
          chips_to_pot_current_bet_round: chips_to_pot_current_bet_round
        } = player,
        _chips,
        false = _has_enough_chips?
      ) do
    %{
      player
      | chip_count: 0,
        chips_to_pot_current_bet_round: chips_to_pot_current_bet_round + chip_count,
        status: :all_in
    }
  end

  def reset_player_add_chips(%Player{chip_count: 0} = player, 0 = _chips_won) do
    %{player | status: :eliminated, chips_to_pot_current_bet_round: 0, cards: []}
  end

  def reset_player_add_chips(%Player{chip_count: chip_count} = player, chips_won) do
    %{
      player
      | status: :active,
        chip_count: chip_count + chips_won,
        chips_to_pot_current_bet_round: 0,
        cards: []
    }
  end
end

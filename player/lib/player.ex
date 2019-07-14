defmodule Player do
  defstruct name: nil,
            chip_count: nil,
            cards: [],
            status: :active,
            chips_to_pot_current_bet_round: 0,
            hand_rank_at_showdown: nil

  alias Player.{Create, Chips, Status}

  defdelegate new(name, chip_count), to: Create

  defdelegate add_to_chip_count(player, chips), to: Chips

  defdelegate commit_chips_to_pot(player, chips), to: Chips

  defdelegate reset_player_add_chips(player, chips_won), to: Chips
  defdelegate reset_chips_to_pot_current_bet_round(player), to: Chips
  defdelegate fold(player), to: Status
end

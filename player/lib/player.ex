defmodule Player do
  defstruct name: nil, chip_count: nil, status: :active, cards: []

  @accepted_status [:active, :sitting_out, :disconnected]

  def new(name, chip_count) do
    %Player{name: name, chip_count: chip_count, status: :active}
  end

  def change_player_status(%Player{} = player, status) when status in @accepted_status do
    %{player | status: status}
  end

  def change_player_status(%Player{} = player, _unaccepted_status) do
    player
  end
end

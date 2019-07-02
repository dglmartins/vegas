defmodule Player.Create do
  alias Player

  def new(name, chip_count) do
    %Player{name: name, chip_count: chip_count}
  end
end

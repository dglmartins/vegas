defmodule Card do
  defstruct rank: nil, suit: nil, show: false

  def new(rank, suit) do
    %Card{rank: rank, suit: suit}
  end
end

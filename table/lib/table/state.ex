defmodule Table.State do
  alias Table.{SeatList, Deck}

  defstruct seat_list: nil,
            dealer_seat: nil,
            deck: nil,
            status: :waiting

  # deck_pid: nil

  def new() do
    %Table.State{seat_list: SeatList.new_empty_table(), deck: Deck.new()}
  end
end

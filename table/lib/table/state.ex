defmodule Table.State do
  alias Table.{SeatMap, Deck}

  defstruct table_id: nil,
            seat_map: SeatMap.new_empty_table(),
            dealer_seat: nil,
            deck: Deck.new(),
            status: :waiting

  # deck_pid: nil

  def new(table_id) do
    # {:ok, deck_pid} = Deck.create_deck(table_deck_id)
    %Table.State{table_id: table_id}
  end
end

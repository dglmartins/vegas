defmodule Table.SeatMap do
  def new_empty_table() do
    for _seat <- 1..10 do
      :empty_seat
    end
  end
end

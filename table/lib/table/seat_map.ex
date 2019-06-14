defmodule Table.SeatMap do
  # alias Table.Helpers

  def new_empty_table() do
    Enum.reduce(1..10, %{}, fn seat, acc_map ->
      Map.put(acc_map, seat, :empty_seat)
    end)

    # for seat <- 1..10 do
    #   {Helpers.seat_integer_to_atom(seat), :empty_seat}
    # end
  end
end

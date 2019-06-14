defmodule Table.SeatMap do
  def new_empty_table() do
    Enum.reduce(1..10, %{}, fn seat, acc_map ->
      Map.put(acc_map, seat, :empty_seat)
    end)
  end
end

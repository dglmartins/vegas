defmodule Table.Helpers do
  def seat_integer_to_atom(seat_integer) do
    seat_integer |> Integer.to_string() |> String.to_atom()
  end

  def seat_atom_to_integer(seat_atom) do
    seat_atom |> Atom.to_string() |> String.to_integer()
  end
end

defmodule Table.Player do
  defstruct name: nil, chip_count: nil

  def new(name, chip_count) do
    %Table.Player{name: name, chip_count: chip_count}
  end
end

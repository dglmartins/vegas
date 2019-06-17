defmodule Player do
  defstruct name: nil, chip_count: nil, status: :active

  def new(name, chip_count) do
    %Player{name: name, chip_count: chip_count, status: :active}
  end
end

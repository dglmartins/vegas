defmodule Player.Status do
  def fold(player) do
    %{player | status: :fold}
  end
end

defmodule Dealer.StartHand do
  def start_hand(%{dealer_seat: nil} = table_state) do
    IO.puts("No dealer")
    table_state
  end

  def start_hand(%{seat_map: seat_map} = table_state) do
    active_seat_map = seat_map |> Enum.filter(fn {_seat, player} -> player.status == :active end)
    enough_players? = Enum.count(active_seat_map) >= 2

    start_hand(table_state, enough_players?)
  end

  def start_hand(table_state, false = _enough_players?) do
    IO.puts("Not enough players, need at least 2 active players")
    table_state
  end

  def start_hand(%{current_hand_id: current_hand_id} = table_state, true = _enough_players) do
    table_state
    |> HandSetup.new(current_hand_id + 1)

    # NlHoldemHand.start_hand(table_state, hand_id)
    # |> Action.post_antes()
  end

  # def post_antes(table_state) do
  #   table_state
  #   |> Action.post_antes()
  #   |> process_post_antes()
  # end
  #
  # def process_post_antes(%{status: :end_hand_no_showdown} = table_state) do
  #   table_state
  #   |> process_no_showdown()
  #   |> State.move_dealer_to_left()
  #   |> start_hand()
  # end
end

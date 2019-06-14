defmodule Table.State do
  alias Table.{SeatList, Deck}

  defstruct seat_list: nil,
            dealer_seat_index: nil,
            deck: nil,
            status: :waiting,
            hand_history: []

  # deck_pid: nil

  def new() do
    %Table.State{seat_list: SeatList.new_empty_table(), deck: Deck.new()}
  end

  def move_dealer_to_seat(%Table.State{} = state, new_seat_index)
      when not is_integer(new_seat_index) or new_seat_index > 9 do
    state
  end

  def move_dealer_to_seat(%Table.State{} = state, new_seat_index) do
    %{state | dealer_seat_index: new_seat_index}
  end

  def move_dealer_to_left(%Table.State{dealer_seat_index: nil} = state), do: state

  def move_dealer_to_left(%Table.State{dealer_seat_index: 9} = state) do
    %{state | dealer_seat_index: 0}
  end

  def move_dealer_to_left(%Table.State{dealer_seat_index: dealer_seat_index} = state) do
    %{state | dealer_seat_index: dealer_seat_index + 1}
  end
end

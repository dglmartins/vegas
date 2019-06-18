defmodule NlHoldemHand.Play do
  def deal_hole_card(hand_state, :empty_seat = _player, _card, _seat) do
    IO.puts("no player in seat")
    hand_state
  end

  def deal_hole_card(%{seat_map: seat_map} = hand_state, card, seat) do
    player = seat_map[seat]
    new_seat_map = Map.put(seat_map, seat, %{player | cards: [card | player.cards]})
    %{hand_state | seat_map: new_seat_map}
  end
end

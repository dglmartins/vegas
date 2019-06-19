defmodule NlHoldemHand.Play do
  alias NlHoldemHand.State

  def deal_hole_card(hand_state, :empty_seat = _player, _card, _seat) do
    IO.puts("no player in seat")
    hand_state
  end

  def deal_hole_cards_rule() do
    [show: false, show: false]
  end

  def deal_hole_card(%State{seat_map: seat_map} = hand_state, card, seat) do
    player = seat_map[seat]
    new_seat_map = Map.put(seat_map, seat, %{player | cards: [card | player.cards]})
    %{hand_state | seat_map: new_seat_map}
  end

  def post_antes(%State{ante: ante} = hand_state) do
  end

  def post_blinds(%{sb_seat: sb_seat, bb_seat: bb_seat, sb: sb, bb: bb} = hand_state) do
  end

  def put_chips_in_pot(%State{seat_map: seat_map, pots: pots} = hand_state) do
  end
end

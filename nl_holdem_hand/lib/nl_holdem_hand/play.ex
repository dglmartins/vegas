defmodule NlHoldemHand.Play do
  alias NlHoldemHand.State

  def deal_hole_card(hand_state, :empty_seat = _player, _card, _seat) do
    IO.puts("no player in seat")
    hand_state
  end

  # def deal_action_rules_map() do
  #   %{
  #     deal_hole_cards: [show: false, show: false],
  #     post_pre_action_bets: [all: :antes, sb: :half_min_bet, bb: :min_bet],
  #     action_on: :under_the_gun,
  #     deal_community: [:flop_cards, :flop_cards, :flop_cards],
  #     action_on: :first_left_of_dealer,
  #     deal_community: [:turn_card],
  #     action_on: :first_left_of_dealer,
  #     deal_community: [:river_card],
  #     action_on: :first_left_of_dealer
  #   }
  # end

  def deal_hole_cards(%State{seat_map: seat_map, dealer_seat: dealer_seat} = hand_state) do
    dealer_cards_count = Enum.count(seat_map[dealer_seat].cards)
    next_seat_to_deal = State.get_next_taken_seat(dealer_seat, seat_map)

    deal_hole_cards(hand_state, dealer_cards_count, next_seat_to_deal)
  end

  def deal_hole_cards(
        %State{dealer_seat: dealer_seat} = hand_state,
        dealer_cards_count,
        next_seat_to_deal
      )
      when dealer_cards_count < 2 do
    new_hand_state = deal_hole_card(hand_state, next_seat_to_deal)
    new_seat_map = new_hand_state.seat_map

    next_seat_to_deal = State.get_next_taken_seat(next_seat_to_deal, new_seat_map)

    dealer_cards_count = Enum.count(new_seat_map[dealer_seat].cards)

    deal_hole_cards(new_hand_state, dealer_cards_count, next_seat_to_deal)
  end

  def deal_hole_cards(hand_state, 2, _next_seat_to_deal) do
    hand_state
  end

  def deal_hole_card(%State{seat_map: seat_map, hand_id: hand_id} = hand_state, seat) do
    card = Deck.deal_card(hand_id)
    player = seat_map[seat]
    new_seat_map = Map.put(seat_map, seat, %{player | cards: [card | player.cards]})
    %{hand_state | seat_map: new_seat_map}
  end

  # def post_antes(%State{ante: ante} = hand_state) do
  # end
  #
  # def post_blinds(%{sb_seat: sb_seat, bb_seat: bb_seat, sb: sb, bb: bb} = hand_state) do
  # end
  #
  # def put_chips_in_pot(%State{seat_map: seat_map, pots: pots} = hand_state) do
  # end
end

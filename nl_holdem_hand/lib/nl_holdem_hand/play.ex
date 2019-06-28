defmodule NlHoldemHand.Play do
  # alias NlHoldemHand.State

  @max_seats 10

  def new(%{seat_map: seat_map, dealer_seat: dealer_seat} = table_state, hand_id) do
    %{
      table_state
      | seat_with_action: get_first_to_act_first_round(dealer_seat, seat_map),
        sb_seat: get_next_taken_seat(dealer_seat, seat_map),
        bb_seat: get_bb_seat(dealer_seat, seat_map),
        last_to_act: get_bb_seat(dealer_seat, seat_map),
        deck: Deck.new(),
        hand_id: hand_id
    }
  end

  def get_next_taken_seat(seat_number, seat_map) when seat_number <= @max_seats do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, seat_map, _seat_taken?)
      when seat_number == @max_seats + 1 do
    get_next_taken_seat(1, seat_map, Map.has_key?(seat_map, 1))
  end

  def get_next_taken_seat(seat_number, seat_map, false = _seat_taken?) do
    get_next_taken_seat(seat_number + 1, seat_map, Map.has_key?(seat_map, seat_number + 1))
  end

  def get_next_taken_seat(seat_number, _seat_map, true = _seat_taken?) do
    seat_number
  end

  def get_bb_seat(dealer_seat, seat_map) do
    dealer_seat
    |> get_next_taken_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end

  def get_first_to_act_first_round(dealer_seat, seat_map) do
    dealer_seat
    |> get_bb_seat(seat_map)
    |> get_next_taken_seat(seat_map)
  end

  # def filter_empty_seats(seat_map) do
  #   Enum.filter(seat_map, fn {_seat, player} ->
  #     player != :empty_seat
  #   end)
  # end

  # def leave_hand(hand_state, seat) do
  #   leave_hand(hand_state, seat, Map.has_key?(hand_state.seat_map, seat))
  # end

  # defp leave_hand(%NlHoldemHand.State{seat_map: seat_map} = state, seat, true = _seat_taken?) do
  #   player = %{seat_map[seat] | status: :sitting_out}
  #   %{state | seat_map: Map.put(seat_map, seat, player)}
  # end
  #
  # defp leave_hand(state, _seat, false = _seat_taken?) do
  #   state
  # end

  def deal_hole_card(table_state, :empty_seat = _player, _card, _seat) do
    IO.puts("no player in seat")
    table_state
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

  def deal_hole_cards(%{seat_map: seat_map, dealer_seat: dealer_seat} = table_state) do
    dealer_cards_count = Enum.count(seat_map[dealer_seat].cards)
    next_seat_to_deal = get_next_taken_seat(dealer_seat, seat_map)

    deal_hole_cards(table_state, dealer_cards_count, next_seat_to_deal)
  end

  def deal_hole_cards(
        %{dealer_seat: dealer_seat} = table_state,
        dealer_cards_count,
        next_seat_to_deal
      )
      when dealer_cards_count < 2 do
    new_table_state = deal_hole_card(table_state, next_seat_to_deal)
    new_seat_map = new_table_state.seat_map

    next_seat_to_deal = get_next_taken_seat(next_seat_to_deal, new_seat_map)

    dealer_cards_count = Enum.count(new_seat_map[dealer_seat].cards)

    deal_hole_cards(new_table_state, dealer_cards_count, next_seat_to_deal)
  end

  def deal_hole_cards(new_table_state, 2, _next_seat_to_deal) do
    new_table_state
  end

  def deal_hole_card(%{seat_map: seat_map, deck: deck} = table_state, seat) do
    {card, rest_of_deck} = Deck.deal_card(deck)
    player = seat_map[seat]
    new_seat_map = Map.put(seat_map, seat, %{player | cards: [card | player.cards]})
    %{table_state | seat_map: new_seat_map, deck: rest_of_deck}
  end

  # def post_antes(%State{ante: ante} = hand_state) do
  # end
  #
  # def post_blinds(%{sb_seat: sb_seat, bb_seat: bb_seat, sb: sb, bb: bb} = hand_state) do
  # end
  #
  # def deal_flop(hand_state) do
  # end
  # def deal_turn(hand_state) do
  # end
  #
  # def deal_river(hand_state) do
  # end
  # def pre_flop_action(hand_state) do
  #
  # end
  #
  # def post_flop_action(hand_state) do
  #
  # end
  #
  # def turn_action(hand_state) do
  #
  # end
  #
  # def river_action(hand_state) do
  #
  # end
  #
  # def put_chips_in_pot(%State{seat_map: seat_map, pots: pots} = hand_state) do
  # end
end

defmodule DealerTest do
  use ExUnit.Case
  doctest NlHoldemHand.Dealer

  alias NlHoldemHand.Dealer

  @seat_map %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200)
  }

  @table_state %{
    dealer_seat: 3,
    status: :waiting,
    hand_history: [],
    pre_action_min_bet: 20,
    ante: 0,
    game_type: :nl_holdem,
    pots: [],
    deck: nil,
    community_cards: [],
    seat_with_action: nil,
    last_to_act: nil,
    seat_map: @seat_map,
    table_id: nil,
    current_hand_id: nil,
    current_bet_round: nil,
    sb_seat: nil,
    bb_seat: nil,
    bet_to_call: 20
  }

  test "starts a game" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    assert Enum.count(table_state.seat_map[1].cards) == 2
    assert Enum.count(table_state.seat_map[3].cards) == 2
    assert Enum.count(table_state.seat_map[7].cards) == 2

    assert Enum.count(table_state.deck) == 46

    assert [table_state.pre_action_min_bet, table_state.ante, table_state.dealer_seat] == [
             20,
             0,
             3
           ]

    assert Enum.count(table_state.seat_map) == 3

    [card_one, card_two] = table_state.seat_map[1].cards

    assert table_state.seat_map[1] == %Player{
             cards: [card_one, card_two],
             chip_count: 200,
             name: "Danilo",
             status: :active
           }

    assert card_one.show == false
    assert card_two.show == false

    assert table_state.sb_seat == 7
    assert table_state.bb_seat == 1
    assert table_state.last_to_act == 1
    assert table_state.seat_with_action == 3
    assert table_state.bet_to_call == 20
    # assert table_state.status == :dealing_hole_cards
  end

  test "deals flop" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 43
  end

  test "does not deal another flop with community cards are already on the board" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 43
    assert table_state.status == :action_to_open

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 43
  end

  test "deals turn" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_turn(table_state)
    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 42
  end

  test "does not deal turn with community cards count different than 3" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 0
    assert Enum.count(table_state.deck) == 46

    table_state = Dealer.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 42

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 42
  end

  test "deals river" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_turn(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 5
    assert Enum.count(table_state.deck) == 41
  end

  test "does not deal river with community cards count different than 4" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 0
    assert Enum.count(table_state.deck) == 46

    table_state = Dealer.deal_flop(table_state)
    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 43

    table_state = Dealer.deal_turn(table_state)
    table_state = %{table_state | status: :dealing_community_cards}
    table_state = Dealer.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 5
    assert Enum.count(table_state.deck) == 41
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

defmodule DealTest do
  use ExUnit.Case
  doctest NlHoldemHand.Dealer.Deal

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

  test "deals flop" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 49
  end

  test "does not deal another flop with community cards are already on the board" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 49
    assert table_state.status == :action_to_open

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_flop(table_state)
    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 49
  end

  test "deals turn" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_turn(table_state)
    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 48
  end

  test "does not deal turn with community cards count different than 3" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 0
    assert Enum.count(table_state.deck) == 52

    table_state = Dealer.Deal.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 48

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_turn(table_state)

    assert Enum.count(table_state.community_cards) == 4
    assert Enum.count(table_state.deck) == 48
  end

  test "deals river" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_flop(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_turn(table_state)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 5
    assert Enum.count(table_state.deck) == 47
  end

  test "does not deal river with community cards count different than 4" do
    hand_id = generate_hand_id()

    table_state = Dealer.start_hand(@table_state, hand_id)

    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 0
    assert Enum.count(table_state.deck) == 52

    table_state = Dealer.Deal.deal_flop(table_state)
    table_state = %{table_state | status: :dealing_community_cards}

    table_state = Dealer.Deal.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 3
    assert Enum.count(table_state.deck) == 49

    table_state = Dealer.Deal.deal_turn(table_state)
    table_state = %{table_state | status: :dealing_community_cards}
    table_state = Dealer.Deal.deal_river(table_state)

    assert Enum.count(table_state.community_cards) == 5
    assert Enum.count(table_state.deck) == 47
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

defmodule HoleCardsTest do
  use ExUnit.Case
  doctest HoleCards

  @seat_map %{
    1 => Player.new("Danilo", 200),
    3 => Player.new("Paula", 200),
    7 => Player.new("Michel", 200)
  }

  @table_state %{
    dealer_seat: 3,
    status: :dealing_hole_cards,
    pre_action_min_bet: 20,
    ante: 5,
    community_cards: [],
    seat_with_action: 3,
    last_to_act: 1,
    seat_map: @seat_map,
    sb_seat: 7,
    bb_seat: 1,
    bet_to_call: 5,
    min_raise: 20,
    deck: Deck.new()
  }

  test "deals cards for NL holdem" do
    table_state =
      @table_state
      |> HoleCards.deal([false, false])

    assert Enum.count(table_state.seat_map[1].cards) == 2
    assert Enum.count(table_state.seat_map[3].cards) == 2
    assert Enum.count(table_state.seat_map[7].cards) == 2

    [card_one, card_two] = table_state.seat_map[1].cards
    assert card_one.show == false
    assert card_two.show == false

    assert table_state.status == :posting_antes

    assert Enum.count(table_state.deck) == 46
  end

  test "deals cards for 7 stud" do
    table_state =
      @table_state
      |> HoleCards.deal([false, false, true])

    assert Enum.count(table_state.seat_map[1].cards) == 3
    assert Enum.count(table_state.seat_map[3].cards) == 3
    assert Enum.count(table_state.seat_map[7].cards) == 3

    [card_one, card_two, card_three] = table_state.seat_map[1].cards
    assert card_one.show == false
    assert card_two.show == false
    assert card_three.show == true

    assert table_state.status == :posting_antes

    assert Enum.count(table_state.deck) == 43
  end

  test "deals cards for omaha " do
    table_state =
      @table_state
      |> HoleCards.deal([false, false, false, false])

    assert Enum.count(table_state.seat_map[1].cards) == 4
    assert Enum.count(table_state.seat_map[3].cards) == 4
    assert Enum.count(table_state.seat_map[7].cards) == 4

    [card_one, card_two, card_three, card_four] = table_state.seat_map[1].cards
    assert card_one.show == false
    assert card_two.show == false
    assert card_three.show == false
    assert card_four.show == false

    assert table_state.status == :posting_antes

    assert Enum.count(table_state.deck) == 40
  end

  test "does not deals hole cards when status is not :dealing_hole_cards" do
    table_state = %{@table_state | status: :waiting}

    table_state =
      table_state
      |> HoleCards.deal([false, false])

    #
    assert table_state.seat_map[1].cards == []
    assert table_state.seat_map[3].cards == []
    assert table_state.seat_map[7].cards == []

    assert Enum.count(table_state.deck) == 52
  end
end

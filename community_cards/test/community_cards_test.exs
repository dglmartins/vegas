defmodule CommunityCardsTest do
  use ExUnit.Case
  doctest CommunityCards

  @table_state %{
    status: :dealing_community_cards,
    community_cards: [],
    deck: Deck.new()
  }

  test "deals 1 community cards" do
    table_state =
      @table_state
      |> CommunityCards.deal(1)

    [%Card{show: show}] = table_state.community_cards

    assert Enum.count(table_state.community_cards) == 1

    assert show == true
    assert table_state.status == :action_to_open

    assert Enum.count(table_state.deck) == 51
  end

  test "does not when status incorrect" do
    table_state =
      %{@table_state | status: :dealing_hole_cards}
      |> CommunityCards.deal(1)

    assert Enum.count(table_state.community_cards) == 0

    assert table_state.status == :dealing_hole_cards

    assert Enum.count(table_state.deck) == 52
  end

  test "deals 3 community cards" do
    table_state =
      @table_state
      |> CommunityCards.deal(3)

    [%{show: show_one}, %{show: show_two}, %{show: show_three}] = table_state.community_cards

    assert Enum.count(table_state.community_cards) == 3
    assert show_one == true
    assert show_two == true
    assert show_three == true

    assert table_state.status == :action_to_open

    assert Enum.count(table_state.deck) == 49
  end

  test "deals 3 community cards then one community card, then another community card" do
    table_state =
      @table_state
      |> CommunityCards.deal(3)

    assert Enum.count(table_state.community_cards) == 3

    assert table_state.status == :action_to_open

    assert Enum.count(table_state.deck) == 49

    table_state = %{table_state | status: :dealing_community_cards}

    table_state =
      table_state
      |> CommunityCards.deal(1)

    assert Enum.count(table_state.community_cards) == 4

    assert table_state.status == :action_to_open

    assert Enum.count(table_state.deck) == 48

    table_state = %{table_state | status: :dealing_community_cards}

    table_state =
      table_state
      |> CommunityCards.deal(1)

    assert Enum.count(table_state.community_cards) == 5

    assert table_state.status == :action_to_open

    assert Enum.count(table_state.deck) == 47

    [
      %{show: show_one},
      %{show: show_two},
      %{show: show_three},
      %{show: show_four},
      %{show: show_five}
    ] = table_state.community_cards

    assert show_one == true
    assert show_two == true
    assert show_three == true
    assert show_four == true
    assert show_five == true
  end
end

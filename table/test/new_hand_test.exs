defmodule NewHandTest do
  use ExUnit.Case
  doctest Table.Dealer.NewHand

  alias Table.{State, Dealer}

  @min_bet 10
  @ante 0
  @game_type :nl_holdem

  test "starts a nl_holdem hand" do
    hand_id = generate_hand_id()

    table_state = State.new(@min_bet, @ante, @game_type)

    player = %{name: "Danilo", chips_at_table: 200, cards: []}
    player_two = %{name: "Paula", chips_at_table: 200, cards: []}
    player_three = %{name: "Michel", chips_at_table: 200, cards: []}
    player_four = %{name: "Renato", chips_at_table: 200, cards: []}

    {status, table_state} = State.join_table(table_state, player, 1)
    {status, table_state} = State.join_table(table_state, player_two, 3)
    {status, table_state} = State.join_table(table_state, player_three, 7)
    {status, table_state} = State.join_table(table_state, player_four, 9)

    table_state = %{table_state | dealer_seat: 3}

    table_state = Dealer.NewHand.start_hand(table_state, hand_id)
  end

  defp generate_hand_id() do
    "hand-#{:rand.uniform(1_000_000)}"
  end
end

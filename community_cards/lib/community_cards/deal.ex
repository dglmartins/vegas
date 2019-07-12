defmodule CommunityCards.Deal do
  def deal(
        %{
          status: :dealing_community_cards,
          deck: deck,
          community_cards: community_cards
        } = table_state,
        number_of_cards
      ) do
    {community_cards, deck} = deal(community_cards, number_of_cards, deck)
    %{table_state | community_cards: community_cards, deck: deck, status: :action_to_open}
  end

  def deal(%{status: status} = table_state, _number_of_cards) do
    IO.puts("Cannot deal community cards when status is #{to_string(status)}")
    table_state
  end

  def deal(community_cards, 0 = _number_of_cards_left_to_deal, deck) do
    {community_cards, deck}
  end

  def deal(community_cards, number_of_cards_left_to_deal, [first_card | rest_of_deck])
      when number_of_cards_left_to_deal > 0 do
    community_cards = community_cards ++ [Card.show(first_card)]
    number_of_cards_left_to_deal = number_of_cards_left_to_deal - 1
    deal(community_cards, number_of_cards_left_to_deal, rest_of_deck)
  end
end

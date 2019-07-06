defmodule RankHand do
  defstruct hand: [], main_rank: nil, tie_breakers: []

  @royal_flush 10
  @straight_flush 9
  @four_of_a_kind 8
  @full_house 7
  @flush 6
  @straight 5
  @three_of_a_kind 4
  @two_pair 3
  @one_pair 2
  @high_card 1

  def get_rank_hole_board(hole_cards, board) do
    (hole_cards ++ board)
    |> Combination.combine(5)
    |> get_best_hand_ranked()
  end

  defp get_best_hand_ranked(all_five_card_hands) do
    all_five_card_hands
    |> Stream.map(&get_list_of_rank_suit_tuples/1)
    |> Stream.map(&sort_hand/1)
    |> Stream.map(&rank_hand/1)
    |> Enum.max_by(&{&1.main_rank, &1.tie_breakers})
  end

  defp get_list_of_rank_suit_tuples(five_card_hand) do
    five_card_hand
    |> Enum.map(fn %Card{rank: rank, suit: suit} -> {rank, suit} end)
  end

  defp sort_hand(hand) do
    Enum.sort(hand, fn {a, _}, {b, _} -> b >= a end)
  end

  defp rank_hand([{10, suit}, {11, suit}, {12, suit}, {13, suit}, {14, suit}] = hand),
    do: %RankHand{hand: hand, main_rank: @royal_flush}

  defp rank_hand(
         [{rank1, suit}, {rank2, suit}, {rank3, suit}, {rank4, suit}, {rank5, suit}] = hand
       )
       when rank1 + 1 == rank2 and rank2 + 1 == rank3 and rank3 + 1 == rank4 and
              rank4 + 1 == rank5,
       do: %RankHand{hand: hand, main_rank: @straight_flush, tie_breakers: [rank5]}

  defp rank_hand([{2, suit}, {3, suit}, {4, suit}, {5, suit}, {14, suit}] = hand),
    do: %RankHand{hand: hand, main_rank: @straight_flush, tie_breakers: [5]}

  defp rank_hand([{kicker, _}, {rank, _}, {rank, _}, {rank, _}, {rank, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @four_of_a_kind,
      tie_breakers: [rank, kicker]
    }

  defp rank_hand([{rank, _}, {rank, _}, {rank, _}, {rank, _}, {kicker, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @four_of_a_kind,
      tie_breakers: [rank, kicker]
    }

  defp rank_hand([{pair, _}, {pair, _}, {set, _}, {set, _}, {set, _}] = hand),
    do: %RankHand{hand: hand, main_rank: @full_house, tie_breakers: [set, pair]}

  defp rank_hand([{set, _}, {set, _}, {set, _}, {pair, _}, {pair, _}] = hand),
    do: %RankHand{hand: hand, main_rank: @full_house, tie_breakers: [set, pair]}

  defp rank_hand(
         [{rank1, suit}, {rank2, suit}, {rank3, suit}, {rank4, suit}, {rank5, suit}] = hand
       ),
       do: %RankHand{
         hand: hand,
         main_rank: @flush,
         tie_breakers: [rank5, rank4, rank3, rank2, rank1]
       }

  defp rank_hand([{rank1, _}, {rank2, _}, {rank3, _}, {rank4, _}, {rank5, _}] = hand)
       when rank1 + 1 == rank2 and rank2 + 1 == rank3 and rank3 + 1 == rank4 and
              rank4 + 1 == rank5,
       do: %RankHand{hand: hand, main_rank: @straight, tie_breakers: [rank5]}

  defp rank_hand([{2, _}, {3, _}, {4, _}, {5, _}, {14, _}] = hand),
    do: %RankHand{hand: hand, main_rank: @straight, tie_breakers: [5]}

  defp rank_hand([{rank, _}, {rank, _}, {rank, _}, {kicker1, _}, {kicker2, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @three_of_a_kind,
      tie_breakers: [rank, kicker2, kicker1]
    }

  defp rank_hand([{kicker1, _}, {rank, _}, {rank, _}, {rank, _}, {kicker2, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @three_of_a_kind,
      tie_breakers: [rank, kicker2, kicker1]
    }

  defp rank_hand([{kicker1, _}, {kicker2, _}, {rank, _}, {rank, _}, {rank, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @three_of_a_kind,
      tie_breakers: [rank, kicker2, kicker1]
    }

  defp rank_hand([{rank1, _}, {rank1, _}, {rank2, _}, {rank2, _}, {kicker, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @two_pair,
      tie_breakers: [rank2, rank1, kicker]
    }

  defp rank_hand([{kicker, _}, {rank1, _}, {rank1, _}, {rank2, _}, {rank2, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @two_pair,
      tie_breakers: [rank2, rank1, kicker]
    }

  defp rank_hand([{rank, _}, {rank, _}, {kicker1, _}, {kicker2, _}, {kicker3, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @one_pair,
      tie_breakers: [rank, kicker3, kicker2, kicker1]
    }

  defp rank_hand([{kicker1, _}, {rank, _}, {rank, _}, {kicker2, _}, {kicker3, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @one_pair,
      tie_breakers: [rank, kicker3, kicker2, kicker1]
    }

  defp rank_hand([{kicker1, _}, {kicker2, _}, {rank, _}, {rank, _}, {kicker3, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @one_pair,
      tie_breakers: [rank, kicker3, kicker2, kicker1]
    }

  defp rank_hand([{kicker1, _}, {kicker2, _}, {kicker3, _}, {rank, _}, {rank, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @one_pair,
      tie_breakers: [rank, kicker3, kicker2, kicker1]
    }

  defp rank_hand([{rank1, _}, {rank2, _}, {rank3, _}, {rank4, _}, {rank5, _}] = hand),
    do: %RankHand{
      hand: hand,
      main_rank: @high_card,
      tie_breakers: [rank5, rank4, rank3, rank2, rank1]
    }
end

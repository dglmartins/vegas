defmodule RankHandTest do
  use ExUnit.Case
  doctest NlHoldemHand.RankHand

  alias NlHoldemHand.RankHand

  test "finds best hand between hand and board" do
    hole_cards = [Card.new(9, :spades), Card.new(9, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(2, :diamonds),
      Card.new(3, :clubs),
      Card.new(5, :diamonds),
      Card.new(2, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 7
    assert tie_breakers == [9, 2]
  end

  test "plays the board on high card" do
    hole_cards = [Card.new(2, :spades), Card.new(5, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(7, :clubs),
      Card.new(10, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 1
    assert tie_breakers == [12, 10, 9, 7, 6]
  end

  test "plays the high card hand between board one high hole card" do
    hole_cards = [Card.new(2, :spades), Card.new(13, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(7, :clubs),
      Card.new(10, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 1
    assert tie_breakers == [13, 12, 10, 9, 7]
  end

  test "plays the high card hand between board two high hole card" do
    hole_cards = [Card.new(14, :spades), Card.new(13, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(7, :clubs),
      Card.new(10, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 1
    assert tie_breakers == [14, 13, 12, 10, 9]
  end

  test "plays the board with a pair with board kickers" do
    hole_cards = [Card.new(5, :spades), Card.new(3, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(9, :diamonds),
      Card.new(13, :clubs),
      Card.new(10, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 2
    assert tie_breakers == [9, 13, 12, 10]
  end

  test "plays the board with a pair with one hole kicker" do
    hole_cards = [Card.new(5, :spades), Card.new(14, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(9, :diamonds),
      Card.new(13, :clubs),
      Card.new(10, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 2
    assert tie_breakers == [9, 14, 13, 12]
  end

  test "plays the board with a pair with two hole kicker" do
    hole_cards = [Card.new(8, :spades), Card.new(14, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(9, :diamonds),
      Card.new(3, :clubs),
      Card.new(2, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 2
    assert tie_breakers == [9, 14, 12, 8]
  end

  test "makes a pair with one hole card and board kicker" do
    hole_cards = [Card.new(9, :spades), Card.new(4, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(8, :diamonds),
      Card.new(5, :clubs),
      Card.new(7, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 2
    assert tie_breakers == [9, 12, 8, 7]
  end

  test "makes a pair with one hole card and hole kicker" do
    hole_cards = [Card.new(9, :spades), Card.new(14, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(8, :diamonds),
      Card.new(5, :clubs),
      Card.new(7, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 2
    assert tie_breakers == [9, 14, 12, 8]
  end

  test "plays the board two pair" do
    hole_cards = [Card.new(3, :spades), Card.new(2, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(9, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 3
    assert tie_breakers == [9, 5, 12]
  end

  test "plays a kicker on two pair board" do
    hole_cards = [Card.new(14, :spades), Card.new(2, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(9, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 3
    assert tie_breakers == [9, 5, 14]
  end

  test "makes two pair with one hole card, board kicker" do
    hole_cards = [Card.new(2, :spades), Card.new(9, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 3
    assert tie_breakers == [9, 5, 12]
  end

  test "makes two pair with one hole card, hole kicker" do
    hole_cards = [Card.new(14, :spades), Card.new(9, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 3
    assert tie_breakers == [9, 5, 14]
  end

  test "makes two pair with two hole cards, board kicker" do
    hole_cards = [Card.new(6, :spades), Card.new(9, :diamonds)]

    board = [
      Card.new(9, :hearts),
      Card.new(6, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 3
    assert tie_breakers == [9, 6, 12]
  end

  test "plays a set board" do
    hole_cards = [Card.new(6, :spades), Card.new(9, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(14, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 14, 12]
  end

  test "plays a set board, with one kicker" do
    hole_cards = [Card.new(6, :spades), Card.new(13, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(14, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 14, 13]
  end

  test "plays a set board, with two kicker" do
    hole_cards = [Card.new(14, :spades), Card.new(13, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(11, :diamonds),
      Card.new(5, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 14, 13]
  end

  test "plays a set with one hole card, board kickers" do
    hole_cards = [Card.new(5, :spades), Card.new(2, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(11, :diamonds),
      Card.new(7, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 12, 11]
  end

  test "plays a set with one hole card, hole kicker" do
    hole_cards = [Card.new(5, :spades), Card.new(14, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(11, :diamonds),
      Card.new(7, :clubs),
      Card.new(5, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 14, 12]
  end

  test "plays a set with two hole card" do
    hole_cards = [Card.new(5, :spades), Card.new(5, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(11, :diamonds),
      Card.new(7, :clubs),
      Card.new(14, :diamonds),
      Card.new(12, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 4
    assert tie_breakers == [5, 14, 12]
  end

  test "plays a straight board" do
    hole_cards = [Card.new(5, :spades), Card.new(5, :diamonds)]

    board = [
      Card.new(5, :hearts),
      Card.new(6, :diamonds),
      Card.new(7, :clubs),
      Card.new(8, :diamonds),
      Card.new(9, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 5
    assert tie_breakers == [9]
  end

  test "plays a straight one hole" do
    hole_cards = [Card.new(5, :spades), Card.new(2, :diamonds)]

    board = [
      Card.new(2, :hearts),
      Card.new(6, :diamonds),
      Card.new(7, :clubs),
      Card.new(8, :diamonds),
      Card.new(9, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 5
    assert tie_breakers == [9]
  end

  test "plays a straight two hole cards" do
    hole_cards = [Card.new(5, :spades), Card.new(6, :diamonds)]

    board = [
      Card.new(2, :hearts),
      Card.new(3, :diamonds),
      Card.new(7, :clubs),
      Card.new(8, :diamonds),
      Card.new(9, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 5
    assert tie_breakers == [9]
  end

  test "plays a flush on board" do
    hole_cards = [Card.new(5, :spades), Card.new(6, :diamonds)]

    board = [
      Card.new(2, :hearts),
      Card.new(3, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts),
      Card.new(9, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 6
    assert tie_breakers == [9, 8, 7, 3, 2]
  end

  test "plays a flush one card board" do
    hole_cards = [Card.new(10, :hearts), Card.new(6, :diamonds)]

    board = [
      Card.new(2, :hearts),
      Card.new(3, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts),
      Card.new(9, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 6
    assert tie_breakers == [10, 9, 8, 7, 3]
  end

  test "plays a flush two cards hole" do
    hole_cards = [Card.new(10, :hearts), Card.new(12, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(3, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts),
      Card.new(9, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 6
    assert tie_breakers == [12, 10, 9, 8, 7]
  end

  test "plays a full house on the board" do
    hole_cards = [Card.new(10, :hearts), Card.new(12, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(2, :spades),
      Card.new(2, :diamonds),
      Card.new(8, :hearts),
      Card.new(8, :spades)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 7
    assert tie_breakers == [2, 8]
  end

  test "plays a full house one hole" do
    hole_cards = [Card.new(2, :hearts), Card.new(12, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(2, :spades),
      Card.new(4, :diamonds),
      Card.new(8, :hearts),
      Card.new(8, :spades)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 7
    assert tie_breakers == [2, 8]
  end

  test "plays a full house two hole cards" do
    hole_cards = [Card.new(2, :hearts), Card.new(2, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(4, :spades),
      Card.new(4, :diamonds),
      Card.new(8, :hearts),
      Card.new(8, :spades)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 7
    assert tie_breakers == [2, 8]
  end

  test "plays four of a kind on board, board kicker" do
    hole_cards = [Card.new(2, :hearts), Card.new(2, :hearts)]

    board = [
      Card.new(5, :hearts),
      Card.new(4, :spades),
      Card.new(4, :diamonds),
      Card.new(4, :hearts),
      Card.new(4, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 8
    assert tie_breakers == [4, 5]
  end

  test "plays four of a kind one hole board kicker" do
    hole_cards = [Card.new(4, :hearts), Card.new(2, :hearts)]

    board = [
      Card.new(5, :hearts),
      Card.new(4, :spades),
      Card.new(4, :diamonds),
      Card.new(6, :hearts),
      Card.new(4, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 8
    assert tie_breakers == [4, 6]
  end

  test "plays four of a kind two hole cards" do
    hole_cards = [Card.new(4, :clubs), Card.new(4, :spades)]

    board = [
      Card.new(4, :hearts),
      Card.new(4, :spades),
      Card.new(7, :diamonds),
      Card.new(6, :hearts),
      Card.new(10, :clubs)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 8
    assert tie_breakers == [4, 10]
  end

  test "plays straight flush on board" do
    hole_cards = [Card.new(4, :clubs), Card.new(4, :spades)]

    board = [
      Card.new(9, :hearts),
      Card.new(5, :hearts),
      Card.new(6, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 9
    assert tie_breakers == [9]
  end

  test "plays straight flush one hole" do
    hole_cards = [Card.new(4, :clubs), Card.new(4, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(5, :hearts),
      Card.new(6, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 9
    assert tie_breakers == [8]
  end

  test "plays straight flush two hole cards" do
    hole_cards = [Card.new(5, :hearts), Card.new(4, :hearts)]

    board = [
      Card.new(2, :hearts),
      Card.new(14, :hearts),
      Card.new(6, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 9
    assert tie_breakers == [8]
  end

  test "plays royal flush on board" do
    hole_cards = [Card.new(5, :hearts), Card.new(5, :spades)]

    board = [
      Card.new(13, :hearts),
      Card.new(14, :hearts),
      Card.new(12, :hearts),
      Card.new(10, :hearts),
      Card.new(11, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 10
    assert tie_breakers == []
  end

  test "plays royal flush one hole" do
    hole_cards = [Card.new(10, :hearts), Card.new(5, :spades)]

    board = [
      Card.new(13, :hearts),
      Card.new(14, :hearts),
      Card.new(12, :hearts),
      Card.new(2, :hearts),
      Card.new(11, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 10
    assert tie_breakers == []
  end

  test "plays royal flush two hole cards" do
    hole_cards = [Card.new(10, :hearts), Card.new(13, :hearts)]

    board = [
      Card.new(13, :spades),
      Card.new(14, :hearts),
      Card.new(12, :hearts),
      Card.new(2, :hearts),
      Card.new(11, :hearts)
    ]

    %RankHand{main_rank: main_rank, tie_breakers: tie_breakers} =
      RankHand.get_rank_hole_board(hole_cards, board)

    assert main_rank == 10
    assert tie_breakers == []
  end
end

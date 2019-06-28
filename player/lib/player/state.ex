defmodule Player.State do
  defstruct name: nil,
            chip_count_off_tables: nil,
            chip_count_in_tables: %{},
            status_in_tables: %{}

  # cards_in_tables: %{}

  @active :active
  @sitting_out :sitting_out
  @accepted_status [@active, @sitting_out]

  def new(name, chip_count_off_tables) do
    %Player.State{name: name, chip_count_off_tables: chip_count_off_tables}
  end

  def join_table(
        %Player.State{status_in_tables: status_in_tables} = player,
        table_id,
        desired_chip_count
      ) do
    already_joined? = Map.has_key?(status_in_tables, table_id)
    join_table(player, table_id, desired_chip_count, already_joined?)
  end

  def join_table(player, _table_id, _desired_chip_count, true = _already_joined?) do
    player
  end

  def join_table(
        %Player.State{
          status_in_tables: status_in_tables,
          cards_in_tables: cards_in_tables,
          chip_count_off_tables: chip_count_off_tables,
          chip_count_in_tables: chip_count_in_tables
        } = player,
        table_id,
        desired_chip_count,
        false = _already_joined?
      ) do
    desired_chip_count = min(desired_chip_count, chip_count_off_tables)

    %{
      player
      | status_in_tables: Map.put(status_in_tables, table_id, @active),
        cards_in_tables: Map.put(cards_in_tables, table_id, []),
        chip_count_off_tables: chip_count_off_tables - desired_chip_count,
        chip_count_in_tables: Map.put(chip_count_in_tables, table_id, desired_chip_count)
    }
  end

  def leave_table(
        %Player.State{status_in_tables: status_in_tables} = player,
        table_id
      ) do
    player_at_table? = Map.has_key?(status_in_tables, table_id)
    leave_table(player, table_id, player_at_table?)
  end

  def leave_table(player, _table_id, false = _player_at_table?) do
    player
  end

  def leave_table(
        %Player.State{
          status_in_tables: status_in_tables
        } = player,
        table_id,
        true = player_at_table?
      ) do
    sitting_out? = status_in_tables[table_id] == @sitting_out
    leave_table(player, table_id, player_at_table?, sitting_out?)
  end

  def leave_table(
        %Player.State{
          status_in_tables: status_in_tables
        } = player,
        table_id,
        true = _player_at_table?,
        false = _sitting_out?
      ) do
    %{
      player
      | status_in_tables: Map.put(status_in_tables, table_id, @sitting_out)
    }
  end

  def leave_table(
        %Player.State{
          status_in_tables: status_in_tables,
          cards_in_tables: cards_in_tables,
          chip_count_off_tables: chip_count_off_tables,
          chip_count_in_tables: chip_count_in_tables
        } = player,
        table_id,
        true = _player_at_table?,
        true = _sitting_out?
      ) do
    chip_count_in_table = chip_count_in_tables[table_id]

    %{
      player
      | status_in_tables: Map.delete(status_in_tables, table_id),
        cards_in_tables: Map.delete(cards_in_tables, table_id),
        chip_count_off_tables: chip_count_off_tables + chip_count_in_table,
        chip_count_in_tables: Map.delete(chip_count_in_tables, table_id)
    }
  end

  def change_player_status_in_table(player, status_in_table, table_id)
      when status_in_table in @accepted_status do
    playing_at_table? = Map.has_key?(player.status_in_tables, table_id)
    change_player_status_in_table(player, status_in_table, table_id, playing_at_table?)
  end

  def change_player_status_in_table(%Player.State{} = player, _unaccepted_status, _table_id) do
    player
  end

  def change_player_status_in_table(player, status_in_table, table_id, true = _playing_at_table?) do
    %{player | status_in_tables: Map.put(player.status_in_tables, table_id, status_in_table)}
  end

  def change_player_status_in_table(
        player,
        _status_in_table,
        _table_id,
        false = _playing_at_table?
      ) do
    player
  end

  # def deal_hole_card(%Player.State{status_in_tables: status_in_tables} = player, table_id, card) do
  #   alread_joined? = Map.has_key?(status_in_tables, table_id)
  #   deal_hole_card(player, table_id, card, alread_joined?)
  # end
  #
  # def deal_hole_card(
  #       %Player.State{cards_in_tables: cards_in_tables} = player,
  #       table_id,
  #       card,
  #       true = _already_joined?
  #     ) do
  #   new_cards = [card | cards_in_tables[table_id]]
  #
  #   %{player | cards_in_tables: Map.put(cards_in_tables, table_id, new_cards)}
  # end
  #
  # def deal_hole_card(player, _table_id, _card, false = _already_joined?) do
  #   player
  # end
end

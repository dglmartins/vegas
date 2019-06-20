defmodule Player do
  defstruct name: nil,
            chip_count_off_tables: nil,
            chip_count_in_tables: %{},
            status_in_tables: %{},
            cards: []

  @active :active
  @sitting_out :sitting_out
  @accepted_status [@active, @sitting_out]

  def new(name, chip_count_off_tables) do
    %Player{name: name, chip_count_off_tables: chip_count_off_tables}
  end

  def join_table(%Player{status_in_tables: status_in_tables} = player, table_id) do
    already_joined? = Map.has_key?(status_in_tables, table_id)
    join_table(player, table_id, already_joined?)
  end

  def join_table(
        player,
        table_id,
        false = _already_joined?
      ) do
    %{player | status_in_tables: Map.put(player.status_in_tables, table_id, @active)}
  end

  def join_table(player, _table_id, true = _already_joined?) do
    player
  end

  def change_player_status_in_table(player, status_in_table, table_id)
      when status_in_table in @accepted_status do
    playing_at_table? = Map.has_key?(player.status_in_tables, table_id)
    change_player_status_in_table(player, status_in_table, table_id, playing_at_table?)
  end

  def change_player_status_in_table(%Player{} = player, _unaccepted_status, _table_id) do
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
end

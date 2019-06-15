defmodule Table do
  alias Table.{TableSupervisor, TableServer}

  defdelegate new(table_id, min_bet, ante, game_type), to: TableSupervisor
  defdelegate table_pid(table_id), to: TableServer
  defdelegate table_ids(), to: TableSupervisor
  defdelegate deal_card(table_id), to: TableServer
  defdelegate reshuffle(table_id), to: TableServer
  defdelegate stop_table(table_id), to: TableSupervisor
end

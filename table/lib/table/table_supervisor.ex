defmodule Table.TableSupervisor do
  @moduledoc """
  A supervisor that starts `Server` processes dynamically.
  """

  use DynamicSupervisor

  alias Table.TableServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `TableServer` process and supervises it.
  """
  def new(table_id, min_bet, ante) do
    child_spec = %{
      id: TableServer,
      start: {TableServer, :start_link, [table_id, min_bet, ante]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates the `TableServer` process normally. It won't be restarted.
  """
  def stop_table(table_id) do
    TableServer.stop_table(table_id)

    child_pid = TableServer.table_pid(table_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  # get tables running
  def table_ids() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, table_pid, _, _} ->
      Registry.keys(Table.TableRegistry, table_pid) |> List.first()
    end)
    |> Enum.sort()
  end
end

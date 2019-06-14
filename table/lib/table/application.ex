defmodule Table.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Table.TableRegistry},
      Table.TableSupervisor
    ]

    :ets.new(:tables_table, [:public, :named_table])

    opts = [strategy: :one_for_one, name: Table.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

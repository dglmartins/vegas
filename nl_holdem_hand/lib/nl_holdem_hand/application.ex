defmodule NlHoldemHand.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: NlHoldemHand.HandRegistry},
      NlHoldemHand.HandSupervisor
    ]

    :ets.new(:hands_table, [:public, :named_table])

    opts = [strategy: :one_for_one, name: NlHoldemHand.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

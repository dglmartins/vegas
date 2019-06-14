defmodule Deck.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Deck.DeckRegistry},
      Deck.DeckSupervisor
    ]

    opts = [strategy: :one_for_one, name: Deck.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

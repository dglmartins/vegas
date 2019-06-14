defmodule Deck.DeckSupervisor do
  @moduledoc """
  A supervisor that starts `Server` processes dynamically.
  """

  use DynamicSupervisor

  alias Deck.DeckServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `GameServer` process and supervises it.
  """
  def create_deck(deck_id) do
    child_spec = %{
      id: DeckServer,
      start: {DeckServer, :start_link, [deck_id]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates the `GameServer` process normally. It won't be restarted.
  """
  def stop_deck(deck_id) do
    DeckServer.stop_deck(deck_id)

    child_pid = DeckServer.deck_pid(deck_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  # get decks running
  def deck_ids() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, game_pid, _, _} ->
      Registry.keys(Deck.DeckRegistry, game_pid) |> List.first()
    end)
    |> Enum.sort()
  end
end

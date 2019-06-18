defmodule NlHoldemHand.HandSupervisor do
  @moduledoc """
  A supervisor that starts `Server` processes dynamically.
  """

  use DynamicSupervisor

  alias NlHoldemHand.HandServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `HandServer` process and supervises it.
  """
  def new(hand_id, table_id, min_bet, ante, seat_map, dealer_seat) do
    child_spec = %{
      id: HandServer,
      start: {HandServer, :start_link, [hand_id, table_id, min_bet, ante, seat_map, dealer_seat]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates the `HandServer` process normally. It won't be restarted.
  """
  def stop_hand(hand_id) do
    HandServer.stop_hand(hand_id)

    child_pid = HandServer.hand_pid(hand_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  # get hands running
  def hands_ids() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, hand_pid, _, _} ->
      Registry.keys(NlHoldemHand.HandRegistry, hand_pid) |> List.first()
    end)
    |> Enum.sort()
  end
end

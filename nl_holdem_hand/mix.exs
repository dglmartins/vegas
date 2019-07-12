defmodule NlHoldemHand.MixProject do
  use Mix.Project

  def project do
    [
      app: :nl_holdem_hand,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:deck, path: "../deck"},
      {:seat_helpers, path: "../seat_helpers"},
      {:player, path: "../player"},
      {:hand_setup, path: "../hand_setup"},
      {:hole_cards, path: "../hole_cards"},
      {:community_cards, path: "../community_cards"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

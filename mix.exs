defmodule Dogirc.Mixfile do
  use Mix.Project

  def project do
    [app: :dogirc,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger, :socket],
      mod: {Dogirc, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:dogma, "~>0.0", only: ~w(dev test)a},
      {:mix_test_watch, only: :dev},
      {:socket, "~> 0.2.8"}
    ]
  end
end

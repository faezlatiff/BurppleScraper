defmodule Atlas.MixProject do
  use Mix.Project

  def project do
    [
      app: :atlas,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Atlas.Application, []}
    ]
  end

  defp deps do
    [
      {:meeseeks, "~> 0.17.0"},
      {:crawly, "~> 0.15.0"},
      {:floki, "~> 0.33.0"},
      {:hound, "~> 1.0"},
      {:jason, "~> 1.2"}
    ]
  end
end

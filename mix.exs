defmodule Kraken.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kraken,
      version: "0.1.2",
      elixir: "~> 1.5",
      description: "REST API wrapper to communicate with Kraken exchange.",
      docs: [extras: ["README.md"]],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps()
    ]
  end

  def package do
    [
      name: :kraken,
      files: ["lib", "mix.exs"],
      maintainers: ["Vyacheslav Voronchuk"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/Voronchuk/kraken"},
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Kraken, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/stub_modules"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:gen_stage, "~> 0.12"},
      {:jason, "~> 1.0.0-rc.1"},

      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end

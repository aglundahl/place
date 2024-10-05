defmodule Place.MixProject do
  use Mix.Project

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def project do
    [
      app: :place,
      deps: deps(),
      description: "A dataset of countries, states and cities around the world.",
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      docs: [
        extras: [
          "LICENSE",
          "priv/countries-states-cities-database/LICENSE",
          "README.md"
        ],
        main: "readme"
      ],
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: "https://github.com/aglundahl/place",
      name: "Place",
      package: [
        files: [
          "LICENSE",
          "lib/place",
          "lib/place.ex",
          "mix.exs",
          "priv/countries-states-cities-database",
          "README.md"
        ],
        licenses: ["MIT", "ODbL-1.0"],
        links: %{
          "GitHub" => "https://github.com/aglundahl/place"
        },
        maintainers: ["Andreas Geffen Lundahl"]
      ],
      source_url: "https://github.com/aglundahl/place",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.3", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:httpoison, "~> 2.2", only: [:dev, :test]},
      {:jason, "~> 1.4", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end

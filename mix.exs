defmodule Textwrap.MixProject do
  use Mix.Project

  def project do
    [
      app: :textwrap,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers(),
      rustler_crates: [
        textwrap_nif: [
          mode: rustc_mode(Mix.env())
        ]
      ],
      name: "Textwrap",
      source_url: "https://github.com/foxbenjaminfox/ex_textwrap",
      homepage_url: "https://github.com/foxbenjaminfox/ex_textwrap",
      docs: docs(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.22.0"},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp rustc_mode(:prod), do: :release
  defp rustc_mode(_), do: :debug

  defp docs() do
    [
      main: "Textwrap"
    ]
  end

  defp description() do
    """
    A NIF binding to the textwrap crate, for wrapping and indenting text.
    """
  end

  def package() do
    [
      maintainers: "Benjamin Fox",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/foxbenjaminfox/ex_textwrap"},
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        ".formatter.exs",
        "native/textwrap_nif/Cargo.*",
        "native/textwrap_nif/src"
      ]
    ]
  end
end

defmodule Textwrap.MixProject do
  use Mix.Project

  def project do
    [
      app: :textwrap,
      version: "0.4.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers(),
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
      {:rustler, "~> 0.37.0"},
      {:credo, "~> 1.7.12", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

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

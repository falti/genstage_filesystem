defmodule GenstageFilesystem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :genstage_filesystem,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gen_stage, :tap],
      mod: {GenstageFilesystem.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.12"},
      {:tap, "~> 0.1"}
    ]
  end

  defp aliases do
  [
    test: "test --no-start"
  ]
  end
end

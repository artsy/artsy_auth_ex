defmodule ArtsyAuthEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :artsy_auth_ex,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.20", only: :dev},
      {:plug_cowboy, "~> 2.0"},
      {:joken, "~> 2.0"},
      {:oauth2, "~> 1.0"},
      {:jason, "~> 1.0"}
    ]
  end

  defp description do
    """
    Library for adding Artsy's omniauth based authentication to your app.
    """
  end

  defp package do
    [
      maintainers: ["Ashkan Nasseri"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/artsy/artsy_auth_ex"}
    ]
  end
end

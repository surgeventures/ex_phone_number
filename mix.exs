defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_phone_number,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:sweet_xml, "~> 0.6"},
      {:pavlov, git: "https://github.com/sproutapp/pavlov.git", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:credo, "~> 0.3", only: [:dev, :test]}
    ]
  end
end

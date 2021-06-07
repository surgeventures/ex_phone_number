defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_phone_number,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.1"},
      {:ex_spec, "~> 2.0", only: :test},
      {:excoveralls, "~> 0.5.6", only: :test},
      {:credo, "~> 0.4.11", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      licenses: [],
      links: %{"GitHub" => "https://github.com/surgeventures/heartbeats"},
      organization: "fresha"
    ]
  end

  defp description do
    """
    A universal solution for health checking elixir apps.
    """
  end
end

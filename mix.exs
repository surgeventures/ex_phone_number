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

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6"},
      {:pavlov, git: "https://github.com/sproutapp/pavlov.git", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:credo, "~> 0.3", only: [:dev, :test]}
    ]
  end
end

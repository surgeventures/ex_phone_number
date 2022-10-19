defmodule ExPhoneNumber.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_phone_number,
      version: "0.3.2",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "ExPhoneNumber",
      source_url: "https://github.com/surgeventures/ex_phone_number",
      homepage_url: "https://github.com/surgeventures/ex_phone_number",
      dialyzer: [
        plt_add_apps: [:inets, :mix]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.7.2"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:ex_spec, "~> 2.0", only: :test},
      {:credo, "~> 1.6.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    A library for parsing, formatting, and validating international phone numbers. Based on Google's libphonenumber.
    """
  end

  defp package do
    [
      files: ["lib", "config", "resources", "LICENSE*", "README*", "mix.exs"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/surgeventures/ex_phone_number"},
      maintainers: ["ClubCollect (@socialpaymentsbv)", "Jose Miguel Rivero Bruno (@josemrb)"],
      name: :ex_phone_number_fresha
    ]
  end
end

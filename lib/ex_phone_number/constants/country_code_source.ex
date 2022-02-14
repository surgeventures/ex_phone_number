defmodule ExPhoneNumber.Constants.CountryCodeSource do
  @moduledoc false

  def from_number_with_plus_sign(), do: :from_number_with_plus_sign

  def from_number_with_idd(), do: :from_number_with_idd

  def from_number_without_plus_sign(), do: :from_number_without_plus_sign

  def from_default_country(), do: :from_default_country
end

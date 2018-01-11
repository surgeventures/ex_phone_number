defmodule ExPhoneNumber.Constants.ValidationResults do
  def is_possible(), do: :is_possible

  def invalid_country_code(), do: :invalid_country_code

  def too_short(), do: :too_short

  def too_long(), do: :too_long

  def invalid_length(), do: :invalid_length

  def is_possible_local_only(), do: :is_possible_local_only
end

defmodule ExPhoneNumber.Validation do
  import ExPhoneNumber.Util
  alias ExPhoneNumber.Constant.ErrorMessage
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.PhoneNumber

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Value.max_input_string_length do
      {:error, ErrorMessage.too_long()}
    else
      {:ok, number_to_parse}
    end
  end

  def is_viable_phone_number?(phone_number) do
    cond do
      String.length(phone_number) < Value.min_length_for_nsn ->
        false
      true ->
        matches_entirely?(Pattern.valid_phone_number_pattern, phone_number)
    end
  end

  def is_valid_number?(%PhoneNumber{} = number) do
    region_code = Metadata.get_region_code_for_number(number)
    is_valid_number_for_region?(number, region_code)
  end

  def is_valid_number_for_region?(%PhoneNumber{} = number, region_code) when is_binary(region_code) do
    :ok
  end
end

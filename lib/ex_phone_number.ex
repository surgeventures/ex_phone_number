defmodule ExPhoneNumber do
  defdelegate format(phone_number, phone_number_format), to: ExPhoneNumber.Formatting

  defdelegate get_number_type(phone_number), to: ExPhoneNumber.Validation

  defdelegate is_possible_number?(number), to: ExPhoneNumber.Validation

  defdelegate is_possible_number?(number, region_code), to: ExPhoneNumber.Parsing

  defdelegate is_valid_number?(number), to: ExPhoneNumber.Validation

  defdelegate parse(number_to_parse, default_region), to: ExPhoneNumber.Parsing
end

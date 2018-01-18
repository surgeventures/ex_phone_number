defmodule ExPhoneNumber.Utilities do
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def is_nil_or_empty?(nil), do: true
  def is_nil_or_empty?(string) when is_binary(string), do: String.length(string) == 0
  def is_nil_or_empty?(_), do: false

  def is_number_matching_description?(number, %PhoneNumberDescription{} = description) when is_binary(number) do
    actual_length = String.length(number)
    if length(description.possible_lengths) > 0 && not actual_length in description.possible_lengths do
      false
    else
      matches_national_number?(number, description, false)
    end
  end

  def matches_national_number?(number, %PhoneNumberDescription{national_number_pattern: ""}, _allow_prefix), do: false
  def matches_national_number?(number, %PhoneNumberDescription{national_number_pattern: nil}, _allow_prefix), do: false
  def matches_national_number?(number, %PhoneNumberDescription{national_number_pattern: national_number_pattern}, allow_prefix) do
    matches_entirely?(number, national_number_pattern, allow_prefix)
  end
  def matches_national_number?(_number, _description, _allow_prefix), do: false

  def matches_entirely?(_number, nil, _allow_prefix), do: false
  def matches_entirely?(_number, "", _allow_prefix), do: false
  def matches_entirely?(_number, "NA", _allow_prefix), do: false
  def matches_entirely?(number, pattern, allow_prefix) do
    regex = ~r/^(?:#{pattern.source})$/
    case Regex.run(regex, number, return: :index) do
      [{_index, length} | _tail] -> Kernel.byte_size(number) == length || allow_prefix
      _ -> false
    end
  end
end

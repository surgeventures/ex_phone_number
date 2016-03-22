defmodule ExPhoneNumber.PhoneNumberUtil do
  import ExPhoneNumber.Extraction
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constant.ErrorMessage
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value

  def parse(number_to_parse, _region) when is_nil(number_to_parse), do: {:error, ErrorMessage.not_a_number}
  def parse(number_to_parse, region) when is_binary(number_to_parse) and is_binary(region) do
    validate_length(number_to_parse) # {:ok // {:error
    build_national_number_for_parsing(number_to_parse) # string
    viable_phone_number?(number_to_parse) # boolean
    check_region_for_parsing(number_to_parse, region) # boolean
    maybe_strip_extension(number_to_parse) # string
  end

  defp build_national_number_for_parsing(number_to_parse) do
    case have_phone_context(number_to_parse) do
      {:true, result} -> parse_rfc3699(number_to_parse, result)
      :false -> extract_possible_number(number_to_parse)
    end
    |> split_at_match_and_return_head(Value.rfc3966_isdn_subaddress)
  end

  defp have_phone_context(number_to_parse) do
    case :binary.match(number_to_parse, Value.rfc3966_phone_context) do
      {pos, length} -> {:true, %{pos: pos, length: length}}
      :nomatch -> :false
    end
  end

  defp parse_rfc3699(number_to_parse, %{pos: pos, length: length}) do
    {:error, "Not implemented. number: #{number_to_parse} pos: #{pos} length: #{length}"}
  end

  defp check_region_for_parsing(number_to_parse, default_region) do
    Metadata.valid_region_code?(default_region) or Regex.match?(Pattern.leading_plus_char_pattern, number_to_parse)
  end

end

defmodule ExPhoneNumber.PhoneNumberUtil do
  import ExPhoneNumber.Extraction
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constant.ErrorMessage
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value
  alias ExPhoneNumber.Constant.ValidationResult
  alias ExPhoneNumber.PhoneNumber
  alias ExPhoneNumber.Metadata

  def parse(number_to_parse, default_region) do
    parse_helper(number_to_parse, default_region, false, true)
  end

  def parse_helper(number_to_parse, _default_region, _keep_raw_input, _check_region) when is_nil(number_to_parse), do: {:error, ErrorMessage.not_a_number}
  def parse_helper(number_to_parse, default_region, keep_raw_input, check_region) when is_binary(number_to_parse) and is_binary(default_region) and is_boolean(keep_raw_input) and is_boolean(check_region) do
    case validate_length(number_to_parse) do
      {:error, message} -> {:error, message}
      {:ok, number_to_parse} ->
        national_number = build_national_number_for_parsing(number_to_parse)
        unless is_viable_phone_number?(national_number) do
          {:error, ErrorMessage.not_a_number}
        else
          if check_region and not check_region_for_parsing(national_number, default_region) do
            {:error, ErrorMessage.invalid_country_code}
          else
            phone_number = if keep_raw_input, do: %PhoneNumber{raw_input: number_to_parse}, else: %PhoneNumber{}
            {ext, national_number} = maybe_strip_extension(national_number)
            phone_number = Map.merge(phone_number, if(not is_nil_or_empty?(ext), do: %{extension: ext}, else: %{}))
            region_metadata = Metadata.get_for_region_code(default_region)
            {result, country_code, normalized_national_number} = Extraction.maybe_extract_country_code(national_number, region_metadata, keep_raw_input)
          end
        end
    end
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
    Metadata.is_valid_region_code?(default_region) or Regex.match?(Pattern.leading_plus_char_pattern, number_to_parse)
  end

  def is_possible_number?(%PhoneNumber{} = number) do
    is_possible_number_with_reason?(number)
  end

  def is_possible_number_with_reason?(%PhoneNumber{} = number) do
    unless Metadata.is_valid_country_code?(number.country_code) do
      ValidationResult.invalid_country_code
    else
      region_code = Metadata.get_region_code_for_country_code(number.country_code)
      metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
      national_number = PhoneNumber.get_national_significant_number(number)
      test_number_length_against_pattern(metadata.general.possible_number_pattern, national_number)
    end
  end
end

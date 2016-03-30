defmodule ExPhoneNumber.Extraction do
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constant.CountryCodeSource
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Metadata.PhoneMetadata

  def extract_possible_number(number_to_parse) do
    case Regex.run(Pattern.valid_start_char_pattern, number_to_parse, return: :index) do
      [{index, _length} | tail] ->
        {_head, tail} = String.split_at(number_to_parse, index)
        tail
        |> split_at_match_and_return_head(Pattern.unwanted_end_char_pattern)
        |> split_at_match_and_return_head(Pattern.second_number_start_pattern)
      nil -> ""
    end
  end

  @doc ~S"""
  Strips any extension (as in, the part of the number dialled after the call is connected, usually indicated with extn, ext, x or similar) from the end of the
  number, and returns it.

  ## Options
    `number` - String. non-normalized telephone number that we wish to strip the extension from.

  Returns tuple {extension, number}
  """
  @spec maybe_strip_extension(String.t) :: tuple
  def maybe_strip_extension(number) do
    case Regex.run(Pattern.extn_pattern, number) do
      [{index, match_length} | tail] ->
        {phone_number_head, phone_number_tail} = String.split_at(number, index)
        if is_viable_phone_number?(phone_number_head) do
          {ext_head, ext_tail} = String.split_at(phone_number_tail, match_length)
          {ext_head, phone_number_head}
        else
          {"", number}
        end
      nil -> {"", number}
    end
  end

  @doc ~S"""
  Tries to extract a country calling code from a number.

  ## Options
    `number` - String. non-normalized telephone number that we wish to extract a country calling code from - may begin with '+'.
    `metadata` - %PhoneMetadata{}. metadata about the region this number may be from.
    `keep_raw_input` - boolean. flag that indicates if country_code_source and preferred_carrier_code should be returned.
  Returns tuple {boolean, carrier_code, number}
  """
  def maybe_extract_country_code(number, metadata, keep_raw_input) when length(number) == 0, do: 0
  def maybe_extract_country_code(number,%PhoneMetadata{} = metadata, keep_raw_input) when is_binary(number) and is_boolean(keep_raw_input) do
    possible_country_idd_prefix = unless is_nil(metadata), do: metadata.international_prefix
    possible_country_idd_prefix = unless is_nil(possible_country_idd_prefix), do: "NonMatch"
    country_code_source = maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix)
  end

  def maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix) when length(number) == 0, do: {CountryCodeSource.from_default_country, ""}
  def maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix) do
    if Regex.match?(Pattern.leading_plus_char_pattern, number) do
      stripped_national_number = Regex.replace(Pattern.leading_plus_char_patterna, "", number)
      {CountryCodeSource.from_number_without_plus_sign, normalize(stripped_national_number)}
    else
      :ok
    end
  end

  def parse_prefix_as_idd(pattern, number) do
    :ok
  end

  @doc ~S"""
  Returns tuple {boolean, carrier_code, number}
  """
  def maybe_strip_national_prefix_and_carrier_code(number, metadata) do
    number_length = String.length(number)
    possible_national_prefix = metadata.national_prefix_for_parsing
    if String.length(number) == 0 or is_nil(possible_national_prefix) or String.length(possible_national_prefix) == 0 do
      {false, "", number}
    else
      :ok
    end
  end
end

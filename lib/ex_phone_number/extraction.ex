defmodule ExPhoneNumber.Extraction do
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  import ExPhoneNumber.Util
  alias ExPhoneNumber.Constant.CountryCodeSource
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Metadata

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

  @doc ~S"""
  Returns tuple {CountryCodeSource, number}
  """
  def maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix) when length(number) == 0, do: {CountryCodeSource.from_default_country, ""}
  def maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix) do
    if Regex.match?(Pattern.leading_plus_char_pattern, number) do
      stripped_national_number = Regex.replace(Pattern.leading_plus_char_patterna, "", number)
      {CountryCodeSource.from_number_without_plus_sign, normalize(stripped_national_number)}
    else
      :ok
    end
  end

  @doc ~S"""
  Returns tuple {boolean, number}
  """
  def parse_prefix_as_idd(pattern, number) do
    case Regex.run(pattern, number, return: :index) do
      [{index, match_length} | tail] ->
        {number_head, number_tail} = String.split_at(index)
        case Regex.run(Pattern.capturing_digit_pattern, number_tail) do
          matches ->
            normalized_group = Normalization.normalize_digits_only(Enum.at(matches, 1))
            if normalized_group == "0" do
              {false, number}
            else
              {true, number_tail}
            end
          nil -> {false, number}
        end
      nil -> {false, number}
    end
  end

  @doc ~S"""
  Returns tuple {boolen, carrier_code, number}
  """
  def maybe_strip_national_prefix_and_carrier_code(number, %PhoneMetadata{} = metadata) do
    maybe_strip_national_prefix_and_carrier_code(number, metadata.national_prefix_for_parsing, metadata.national_prefix_transform_rule, metadata.general.national_number_pattern)
  end
  def maybe_strip_national_prefix_and_carrier_code(number, national_prefix_for_parsing, national_prefix_transform_rule, general_national_number_pattern)
    when is_nil(number) or is_nil(national_prefix_for_parsing), do: {false, "", number}
  def maybe_strip_national_prefix_and_carrier_code(number, national_prefix_for_parsing, national_prefix_transform_rule, general_national_number_pattern)
    when is_binary(number) and is_binary(national_prefix_for_parsing) do
    prefix_pattern = ~r/^(?:#{national_prefix_for_parsing})/
    case Regex.run(prefix_pattern, number) do
      nil -> {false, "", number}
      matches ->
        is_viable_original_number = matches_entirely?(general_national_number_pattern, number)
        number_of_groups = length(matches) - 1
        number_stripped = elem(String.split_at(number, String.length(Enum.at(matches, 0))), 1)
        if is_nil_or_empty?(national_prefix_transform_rule) or is_nil_or_empty?(Enum.at(matches, number_of_groups)) do
          if is_viable_original_number and not matches_entirely?(general_national_number_pattern, number_stripped) do
            {false, "", number}
          else
            carrier_code = if length(matches) > 0 and not is_nil(Enum.at(matches, number_of_groups)), do: Enum.at(matches, 1)
            {true, carrier_code, number_stripped}
          end
        else
          transform_pattern = String.replace(national_prefix_transform_rule, ~r/\$(\d)/, "\\\\g{\\g{1}}")
          transformed_number = Regex.replace(prefix_pattern, number, transform_pattern)
          if is_viable_original_number and not matches_entirely?(general_national_number_pattern, transformed_number) do
            {false, "", number}
          else
            carrier_code = if length(matches) > 0, do: Enum.at(matches, 1)
            {true, carrier_code, transformed_number}
          end
        end
    end
  end

  @doc ~S"""
  Returns tuple {country_code, national_number}
  """
  def extract_country_code(full_number) when is_binary(full_number) do
    if String.length(full_number) == 0 or String.at(full_number, 0) == "0" do
      {0, ""}
    else
      extract_country_code(1, full_number)
    end
  end
  def extract_country_code(index, full_number) when is_number(index) and is_binary(full_number) do
    unless index <= Value.max_length_country_code and index <= String.length(full_number) do
      {0, ""}
    else
      split = String.split_at(full_number, index)
      case Integer.parse(elem(split, 0)) do
        {int, bin} ->
          if Metadata.is_valid_country_code?(int) do
            {int, elem(split, 1)}
          else
            extract_country_code(index+1, full_number)
          end
        :error -> {0, ""}
      end
    end
  end
end

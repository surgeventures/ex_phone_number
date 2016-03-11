defmodule ExPhoneNumber.PhoneNumberUtil do
  import ExPhoneNumber.Extraction
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Util
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value
  alias ExPhoneNumber.Metadata.PhoneNumberMetadata

  def parse(number_to_parse, region) when is_binary(number_to_parse) and is_binary(region) do
    number_to_parse
    |> Validation.validate_length()
    |> build_national_number()
  end

  defp build_national_number(number_to_parse) do
    case have_phone_context(number_to_parse) do
      {:true, result} -> parse_rfc3699(number_to_parse, result)
      :false -> extract_possible_number(number_to_parse)
    end
    |> delete_isdn_subaddress()
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

  def viable_phone_number?(phone_number) do
    if String.length(phone_number) < Value.min_length_for_nsn do
      false
    end
    matches_entirely?(Pattern.valid_phone_number_pattern, phone_number)
  end

  defp check_region(number_to_parse, default_region) do
    PhoneNumberMetadata.valid_region_code?(default_region) or
      Regex.match?(Pattern.leading_plus_char_pattern(), number_to_parse)
  end

  def maybe_strip_extension(phone_number) do
    case Regex.run(Pattern.extn_pattern, phone_number) do
      [{index, length}] ->
        {phone_number_head, phone_number_tail} = String.split_at(phone_number, index)
        if viable_phone_number?(phone_number_head) do
          {ext_head, ext_tail} = String.split_at(phone_number_tail, length)
          ext_head
        else
          ""
        end
      nil -> ""
    end
  end

end

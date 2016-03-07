defmodule ExPhoneNumber.PhoneNumberUtil do

  def parse(number_to_parse, region) when is_binary(number_to_parse) and is_binary(region) do
    number_to_parse
    |> validate_length()
    |> build_national_number()
  end

  @max_input_string_length 250
  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > @max_input_string_length do
      {:error, "The string supplied was too long to parse."}
    else
      {:ok, number_to_parse}
    end
  end

  defp build_national_number(number_to_parse) do
    case have_phone_context(number_to_parse) do
      {:true, result} -> parse_rfc3699(number_to_parse, result)
      :false -> extract_possible_number(number_to_parse)
    end
    |> delete_isdn_subaddress()
  end

  @rfc3966_phone_context ";phone-context="
  defp have_phone_context(number_to_parse) do
    case :binary.match(number_to_parse, @rfc3966_phone_context) do
      {index, length} -> {:true, %{index: index, length: length}}
      :nomatch -> :false
    end
  end

  @plus_sign '+'
  defp parse_rfc3699(number_to_parse, %{index: index, length: length}) do
    {:error, "Not implemented. number: #{number_to_parse} index: #{index} length: #{length}"}
  end

  @plus_chars "+\uFF0B"
  @valid_digits "0-9\uFF10-\uFF19\u0660-\u0669\u06F0-\u06F9"
  @valid_start_char_pattern ~r/[#{@plus_chars}#{@valid_digits}]/u
  def extract_possible_number(number_to_parse) do
    case Regex.run(@valid_start_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {_head, tail} = String.split_at(number_to_parse, index)
        tail
        |> remove_unwanted_end_char_pattern()
        |> remove_second_number()
      nil -> ""
    end
  end

  @valid_alpha "A-Za-z"
  @unwanted_end_char_pattern ~r/[^#{@valid_digits}#{@valid_alpha}#]+$/u
  defp remove_unwanted_end_char_pattern(number_to_parse) do
    case Regex.run(@unwanted_end_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  @second_number_start_pattern ~r/[\\\/] *x/u
  defp remove_second_number(number_to_parse) do
    case Regex.run(@second_number_start_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  @rfc3966_isdn_subaddress ";isub="
  defp delete_isdn_subaddress(number_to_parse) do
    case :binary.match(number_to_parse, @rfc3966_isdn_subaddress) do
      {index, _length} ->
      {head, _tail} = String.split_at(number_to_parse, index)
      head
      :nomatch -> number_to_parse
    end
  end

  @min_length_for_nsn "2"
  @min_length_phone_number_pattern  "[#{@valid_digits}]{#{@min_length_for_nsn}}"
  @valid_punctuation "-x\u2010-\u2015\u2212\u30FC\uFF0D-\uFF0F \u00A0\u00AD\u200B\u2060\u3000()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E"
  @star_sign "*"
  @valid_phone_number "[#{@plus_chars}]*(?:[#{@valid_punctuation}#{@star_sign}]*[#{@valid_digits}]){3,}[#{@valid_punctuation}#{@star_sign}#{@valid_alpha}#{@valid_digits}]*"
  @rfc3966_extn_prefix ";ext="
  @capturing_extn_digits "([#{@valid_digits}]{1,7})"
  @extn_patterns_for_parsing "#{@rfc3966_extn_prefix}#{@capturing_extn_digits}|[ \u00A0\\t,]*(?:e?xt(?:ensi(?:o\u0301?|\u00F3))?n?|\uFF45?\uFF58\uFF54\uFF4E?|[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)[:\\.\uFF0E]?[ \u00A0\\t,-]*#{@capturing_extn_digits}#?|[- ]+([#{@valid_digits}]{1,5})#"
  @valid_phone_number_pattern ~r/^#{@min_length_phone_number_pattern}$|^#{@valid_phone_number}(?:#{@extn_patterns_for_parsing})?$/iu

  def viable_phone_number?(phone_number) do
    String.length(phone_number) < Integer.parse(@min_length_for_nsn) and matches_entirely?(@valid_phone_number_pattern, phone_number)
  end

  defp matches_entirely?(regex, string) do
    case Regex.run(regex, string, return: :index) do
      [{_index, length}] -> String.length(string) == length
      _ -> false
    end
  end
end

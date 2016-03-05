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
    _national_number =
      case have_phone_context(number_to_parse) do
        {:true, result} -> parse_rfc3699(number_to_parse, result)
        :false -> extract_possible_number(number_to_parse)
      end
  end

  @rfc3966_phone_context ";phone-context="
  defp have_phone_context(number_to_parse) do
    case :binary.match(number_to_parse, @rfc3966_phone_context, []) do
      {pos, length} -> {:true, %{pos: pos, length: length}}
      :nomatch -> :false
    end
  end

  @plus_sign '+'
  defp parse_rfc3699(number_to_parse, %{pos: pos, length: length}) do
    {:error, "Not implemented. number: #{number_to_parse} pos: #{pos} length: #{length}"}
  end

  @plus_chars "+\uFF0B"
  @valid_digits "0-9\uFF10-\uFF19\u0660-\u0669\u06F0-\u06F9"
  @valid_start_char_pattern ~r/[#{@plus_chars}#{@valid_digits}]/u
  def extract_possible_number(number_to_parse) do
    case Regex.run(@valid_start_char_pattern, number_to_parse, return: :index) do
      [{index, _match}] ->
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
    String.replace(number_to_parse, @unwanted_end_char_pattern, "")
    case Regex.run(@unwanted_end_char_pattern, number_to_parse, return: :index) do
      [{index, _match}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  @second_number_start_pattern ~r/[\\\/] *x/u
  defp remove_second_number(number_to_parse) do
    case Regex.run(@second_number_start_pattern, number_to_parse, return: :index) do
      [{index, _match}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end
end

defmodule ExPhoneNumber.PhoneNumberUtil do
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value
  import ExPhoneNumber.Util

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

  def extract_possible_number(number_to_parse) do
    case Regex.run(Pattern.valid_start_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {_head, tail} = String.split_at(number_to_parse, index)
        tail
        |> remove_unwanted_end_char_pattern()
        |> remove_second_number()
      nil -> ""
    end
  end

  defp remove_unwanted_end_char_pattern(number_to_parse) do
    case Regex.run(Pattern.unwanted_end_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  defp remove_second_number(number_to_parse) do
    case Regex.run(Pattern.second_number_start_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  defp delete_isdn_subaddress(number_to_parse) do
    case :binary.match(number_to_parse, Value.rfc3966_isdn_subaddress) do
      {pos, _length} ->
      {head, _tail} = String.split_at(number_to_parse, pos)
      head
      :nomatch -> number_to_parse
    end
  end

  def viable_phone_number?(phone_number) do
    if String.length(phone_number) < Value.min_length_for_nsn do
      false
    end
    matches_entirely?(Pattern.valid_phone_number_pattern, phone_number)
  end

end

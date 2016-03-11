defmodule ExPhoneNumber.Normalization do
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value

  def remove_unwanted_end_char_pattern(number_to_parse) do
    case Regex.run(Pattern.unwanted_end_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  def remove_second_number(number_to_parse) do
    case Regex.run(Pattern.second_number_start_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(number_to_parse, index)
        head
      nil -> number_to_parse
    end
  end

  def delete_isdn_subaddress(number_to_parse) do
    case :binary.match(number_to_parse, Value.rfc3966_isdn_subaddress) do
      {pos, _length} ->
      {head, _tail} = String.split_at(number_to_parse, pos)
      head
      :nomatch -> number_to_parse
    end
  end

end

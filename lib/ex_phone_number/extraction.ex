defmodule ExPhoneNumber.Extraction do
  import ExPhoneNumber.Normalization
  alias ExPhoneNumber.Constant.Pattern

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
end

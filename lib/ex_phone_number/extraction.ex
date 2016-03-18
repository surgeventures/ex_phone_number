defmodule ExPhoneNumber.Extraction do
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constant.Pattern

  def extract_possible_number(number_to_parse) do
    case Regex.run(Pattern.valid_start_char_pattern, number_to_parse, return: :index) do
      [{index, _length}] ->
        {_head, tail} = String.split_at(number_to_parse, index)
        tail
        |> split_at_match_and_return_head(Pattern.unwanted_end_char_pattern)
        |> split_at_match_and_return_head(Pattern.second_number_start_pattern)
      nil -> ""
    end
  end

  def maybe_strip_extension(phone_number) do
    case Regex.run(Pattern.extn_pattern, phone_number) do
      [{index, match_length}] ->
        {phone_number_head, phone_number_tail} = String.split_at(phone_number, index)
        if viable_phone_number?(phone_number_head) do
          {ext_head, ext_tail} = String.split_at(phone_number_tail, match_length)
          ext_head
        else
          ""
        end
      nil -> ""
    end
  end
end

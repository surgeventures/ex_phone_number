defmodule ExPhoneNumber.Normalization do
  import ExPhoneNumber.Util
  alias ExPhoneNumber.Constant.Mapping
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value

  def match_at_start?(string, pattern) when is_binary(string) and is_map(pattern) do
    case Regex.run(pattern, string, return: :index) do
      [{index, _length}] -> index == 0
      nil -> false
    end
  end

  def split_at_match_and_return_head(string, pattern) when is_binary(string) and is_map(pattern) do
    case Regex.run(pattern, string, return: :index) do
      [{index, _length}] ->
        {head, _tail} = String.split_at(string, index)
        head
      nil -> string
    end
  end

  def split_at_match_and_return_head(string, pattern) when is_binary(string) and is_binary(pattern) do
    case :binary.match(string, pattern) do
      {pos, _length} ->
        {head, _tail} = String.split_at(string, pos)
        head
      :nomatch -> string
    end
  end

  def is_nil_or_empty?(nil), do: true
  def is_nil_or_empty?(string) when is_binary(string), do: String.length(string) == 0
  def is_nil_or_empty?(_), do: false

  def normalize(number) do
    if matches_entirely?(Pattern.valid_alpha_phone_pattern, number) do
      normalize_helper(number, Mapping.all_normalization_mappings, true)
    else
      normalize_digits_only(number)
    end
  end

  def normalize_digits_only(number) do
    normalize_helper(number, Mapping.digit_mappings, true)
  end

  def convert_alpha_chars_in_number(number) do
    normalize_helper(number, Mapping.all_normalization_mappings, false)
  end

  def normalize_helper(number, normalization_replacements, remove_non_matches) when is_binary(number) and is_map(normalization_replacements) and is_boolean(remove_non_matches) do
    Enum.reduce(String.codepoints(number), [], fn(char, list) ->
      if new_char = Map.get(normalization_replacements, String.upcase(char)) do
        list ++ [new_char]
      else
        if remove_non_matches do
          list
        else
          list ++ [char]
        end
      end
    end)
    |> List.to_string()
  end
end

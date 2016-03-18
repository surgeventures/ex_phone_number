defmodule ExPhoneNumber.Normalization do
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value

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
end

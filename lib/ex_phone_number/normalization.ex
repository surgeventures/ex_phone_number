defmodule ExPhoneNumber.Normalization do

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
end

defmodule ExPhoneNumber.Util do
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  @doc ~S"""
  Returns a boolean indicating whether there was a match and
  is the same size as the `string` parameter.
  """
  @spec matches_entirely?(Regex.t, String.t) :: boolean
  def matches_entirely?(regex, string) do
    case Regex.run(regex, string, return: :index) do
      [{_index, length}] -> Kernel.byte_size(string) == length
      _ -> false
    end
  end

  def is_number_matching_description?(number, %PhoneNumberDescription{} = description) when is_binary(number) do
    matches_entirely?(description.possible_number_pattern, number) and
      matches_entirely?(description.national_number_pattern, number)
  end
end

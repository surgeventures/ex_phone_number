defmodule ExPhoneNumber.Metadata.PhoneNumberDescription do
  defstruct national_number_pattern: nil,   # string
            possible_number_pattern: nil,   # string
            example_number: nil,            # string

            # These represent the lengths a phone number from this region can be. They
            # will be sorted from smallest to biggest. Note that these lengths are for
            # the full number, without country calling code or national prefix. For
            # example, for the Swiss number +41789270000, in local format 0789270000,
            # this would be 9.
            # This could be used to highlight tokens in a text that may be a phone
            # number, or to quickly prune numbers that could not possibly be a phone
            # number for this locale.
            possible_lengths: nil,

            # These represent the lengths that only local phone numbers (without an area
            # code) from this region can be. They will be sorted from smallest to
            # biggest. For example, since the American number 456-1234 may be locally
            # diallable, although not diallable from outside the area, 7 could be a
            # possible value.
            # This could be used to highlight tokens in a text that may be a phone
            # number.
            # To our knowledge, area codes are usually only relevant for some fixed-line
            # and mobile numbers, so this field should only be set for those types of
            # numbers (and the general description) - however there are exceptions for
            # NANPA countries.
            possible_lengths_local_only: nil

  import SweetXml
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def from_xpath_node(nil), do: nil
  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node |> xmap(
        national_number_pattern: ~x"./nationalNumberPattern/text()"o |> transform_by(&normalize_pattern/1),
        possible_number_pattern: ~x"./possibleNumberPattern/text()"o |> transform_by(&normalize_pattern/1),
        example_number: ~x"./exampleNumber/text()"o |> transform_by(&normalize_string/1),
        possible_lengths: ~x"string(./possibleLengths/@national)"o |> transform_by(&extract_lengths/1),
        possible_lengths_local_only: ~x"string(./possibleLengths/@localOnly)"o |> transform_by(&extract_lengths/1)
      )
    struct(%PhoneNumberDescription{}, kwlist)
  end

  defp normalize_string(nil), do: nil
  defp normalize_string(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
  end

  defp normalize_pattern(nil), do: nil
  defp normalize_pattern(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
    |> Regex.compile!()
  end

  defp extract_lengths(nil), do: nil
  defp extract_lengths(char_list) do
    char_list
    |> List.to_string()
    |> String.split(",", trim: true)
    |> Enum.flat_map(&to_integer/1)
    |> case do
      [] -> nil
      lengths -> lengths
    end
  end

  defp to_integer(int) when int in ~w(3 4 5 6 7 8 9 10 11 12 13), do: [String.to_integer(int)]
  defp to_integer(range) do
    range
    |> String.replace(["[", "]"], "")
    |> String.split("-", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> case do
      [lower, upper] -> Enum.to_list(lower..upper)
      [int] -> [int]
    end
  end
end

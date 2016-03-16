defmodule ExPhoneNumber.Metadata.NumberFormat do
  defstruct pattern: nil,                                  # string
            format: nil,                                   # string
            leading_digits_pattern: nil,                   # string
            national_prefix_formatting_rule: nil,          # string
            national_prefix_optional_when_formatting: nil, # boolean
            domestic_carrier_code_formatting_rule: nil     # string

  import SweetXml
  alias ExPhoneNumber.Metadata.NumberFormat

  def from_xpath_node(nil), do: nil
  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node |> xmap(
        pattern: ~x"./@pattern"s,
        format: ~x"./format/text()"s,
        leading_digits_pattern: ~x"./leadingDigits/text()"s |> transform_by(&normalize_pattern/1),
        national_prefix_formatting_rule: ~x"./@nationalPrefixFormattingRule"o,
        national_prefix_optional_when_formatting: ~x"./@nationalPrefixOptionalWhenFormatting"o |> transform_by(&normalize_boolean/1),
        domestic_carrier_code_formatting_rule: ~x"./@carrierCodeFormattingRule"o
      )
    struct(%NumberFormat{}, kwlist)
  end

  defp normalize_pattern(nil), do: nil
  defp normalize_pattern(string) when length(string) == 0, do: nil
  defp normalize_pattern(string) when is_binary(string) do
    string
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
  end

  defp normalize_boolean(nil), do: nil
  defp normalize_boolean(true_char_list) when is_list(true_char_list) and length(true_char_list) == 4, do: true
end

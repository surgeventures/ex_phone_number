defmodule ExPhoneNumber.Metadata.NumberFormat do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field(:pattern, String.t())
    field(:format, String.t())
    field(:leading_digits_pattern, String.t())
    field(:domestic_carrier_code_formatting_rule, String.t())
    field(:intl_format, String.t())
    field(:national_prefix_formatting_rule, String.t())
    field(:national_prefix_optional_when_formatting, boolean)
  end

  import SweetXml
  alias ExPhoneNumber.Metadata.NumberFormat

  def from_xpath_node(nil), do: nil

  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node
      |> xmap(
        pattern: ~x"./@pattern"s |> transform_by(&normalize_pattern/1),
        format: ~x"./format/text()"s |> transform_by(&normalize_rule/1),
        leading_digits_pattern: [
          ~x"./leadingDigits"el,
          pattern: ~x"./text()"s |> transform_by(&normalize_pattern/1)
        ],
        national_prefix_formatting_rule:
          ~x"./@nationalPrefixFormattingRule"o |> transform_by(&normalize_string/1),
        national_prefix_optional_when_formatting:
          ~x"./@nationalPrefixOptionalWhenFormatting"o |> transform_by(&normalize_boolean/1),
        domestic_carrier_code_formatting_rule:
          ~x"./@carrierCodeFormattingRule"o |> transform_by(&normalize_string/1),
        intl_format: ~x"./intlFormat/text()"o |> transform_by(&normalize_rule/1)
      )

    struct(%NumberFormat{}, kwlist)
  end

  defp normalize_boolean(nil), do: nil

  defp normalize_boolean(true_char_list)
       when is_list(true_char_list) and length(true_char_list) == 4,
       do: true

  defp normalize_pattern(nil), do: nil
  defp normalize_pattern(""), do: nil
  defp normalize_pattern([]), do: nil

  defp normalize_pattern(string) when is_binary(string) do
    string
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
    |> Regex.compile!()
  end

  defp normalize_string(nil), do: nil

  defp normalize_string(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
  end

  defp normalize_rule(nil), do: nil

  defp normalize_rule(char_list) when is_list(char_list),
    do: char_list |> List.to_string() |> normalize_rule()

  defp normalize_rule(string) when is_binary(string) do
    string
    |> String.replace(~r/\$(\d)/, "\\\\g{\\g{1}}")
  end
end

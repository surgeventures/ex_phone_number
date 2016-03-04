defmodule ExPhoneNumber.PhoneNumberUtil do

  @doc ~S"""
  public void parse(String numberToParse, String defaultRegion, PhoneNumber phoneNumber)
  ->
  private void parseHelper(String numberToParse, String defaultRegion, boolean keepRawInput,
                             boolean checkRegion, PhoneNumber phoneNumber)
    number, region, false, true, phone_number
  """
  def parse(phone_number, region) when is_binary(phone_number) and is_binary(region) do
    phone_number
    |> validate_length()
    # validate_length
    # build_national_number
  end

  @max_input_string_length 250

  defp validate_length(phone_number) when is_binary(phone_number) do
    if String.length(phone_number) > @max_input_string_length do
      {:error, "The string supplied was too long to parse."}
    else
      {:ok, phone_number}
    end
  end

  @rfc3966_extn_prefix ";ext="
  @rfc3966_prefix "tel:"
  @rfc3966_phone_context ";phone-context="
  @rfc3966_isdn_subaddress ";isub="
  defp build_national_number(phone_number) when is_binary(phone_number) do
    phone_number
    |> parse_phone_context
  end

  @plus_sign '+'
  defp parse_phone_context(phone_number) when is_binary(phone_number) do
    :ok
  end

  @digits "\\p{Nd}"
  @plus_chars "+\uFF0B"
  @valid_start_char "[" <> @plus_chars <> @digits <> "]"
  @valid_start_char_pattern Regex.compile(@valid_start_char)
end

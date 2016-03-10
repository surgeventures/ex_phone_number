defmodule ExPhoneNumber.Validation do
  alias ExPhoneNumber.Constant.ErrorMessage
  alias ExPhoneNumber.Constant.Value

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Value.max_input_string_length do
      {:error, ErrorMessage.too_long}
    else
      {:ok, number_to_parse}
    end
  end
end

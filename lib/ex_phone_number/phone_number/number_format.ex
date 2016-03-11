defmodule ExPhoneNumber.PhoneNumber.NumberFormat do
  defstruct pattern: nil,                                  # string
            format: nil,                                   # string
            leading_digits_pattern: nil,                   # string
            national_prefix_formatting_rule: nil,          # string
            national_prefix_optional_when_formatting: nil, # boolean
            domestic_carrier_code_formatting_rule: nil     # string
end

# ExPhoneNumber

It's a library for parsing, formatting, and validating international phone numbers.
Based on Google's [libphonenumber](https://github.com/googlei18n/libphonenumber).

## Installation

  1. Add ExPhoneNumber to your list of dependencies in `mix.exs`:
```ex
def deps do
  [{:ex_phone_number, git: "https://github.com/socialpaymentsbv/ex_phone_number.git"}]
end
```

## Usage
```ex
iex> {result, phone_number} = ExPhoneNumber.parse("044 668 18 00", "CH")
#> {:ok, %ExPhoneNumber.Model.PhoneNumber{country_code: 41, country_code_source: nil, extension: nil,
#        italian_leading_zero: nil, national_number: 446681800, number_of_leading_zeros: nil,
#        preferred_domestic_carrier_code: nil, raw_input: nil}}

iex> ExPhoneNumber.is_possible_number?(phone_number)
#> true

iex> ExPhoneNumber.is_valid_number?(phone_number)
#> true

iex> ExPhoneNumber.get_number_type(phone_number)
#> :fixed_line

iex> ExPhoneNumber.format(phone_number, :national)
#> "044 668 18 00"

iex> ExPhoneNumber.format(phone_number, :international)
#> "+41 44 668 18 00"

iex> ExPhoneNumber.format(phone_number, :e164)
#> "+41446681800"

iex> ExPhoneNumber.format(phone_number, :rfc3966)
#> "tel:+41-44-668-18-00"
```

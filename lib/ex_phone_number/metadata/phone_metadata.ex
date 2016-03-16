defmodule ExPhoneNumber.Metadata.PhoneMetadata do
  defstruct general_description: nil,                # %PhoneNumberDescription{}
            fixed_line: nil,                         # %PhoneNumberDescription{}
            mobile: nil,                             # %PhoneNumberDescription{}
            toll_free: nil,                          # %PhoneNumberDescription{}
            premium_rate: nil,                       # %PhoneNumberDescription{}
            shared_cost: nil,                        # %PhoneNumberDescription{}
            personal_number: nil,                    # %PhoneNumberDescription{}
            voip: nil,                               # %PhoneNumberDescription{}
            pager: nil,                              # %PhoneNumberDescription{}
            uan: nil,                                # %PhoneNumberDescription{}
            emergency: nil,                          # %PhoneNumberDescription{}
            voicemail: nil,                          # %PhoneNumberDescription{}
            short_code: nil,                         # %PhoneNumberDescription{}
            standard_rate: nil,                      # %PhoneNumberDescription{}
            carrier_specific: nil,                   # %PhoneNumberDescription{}
            no_international_dialing: nil,           # %PhoneNumberDescription{}
            id: nil,                                 # string
            country_code: nil,                       # number
            international_prefix: nil,               # string
            preferred_international_prefix: nil,     # string
            national_prefix: nil,                    # string
            preferred_extn_prefix: nil,              # string
            national_prefix_for_parsing: nil,        # string
            national_prefix_tranform_rule: nil,      # string
            same_mobile_and_fixed_line_pattern: nil, # boolean
            number_format: nil,                      # %NumberFormat{}
            intl_number_format: nil,                 # %NumberFormat{}
            main_country_for_code: nil,              # boolean
            leading_digits: nil,                     # string
            leading_zero_possible: nil,              # boolean
            mobile_number_portable_region: nil       # boolean

  import SweetXml
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Metadata.PhoneNumberDescription
  alias ExPhoneNumber.Metadata.NumberFormat

  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node |> xmap(
        general_description: ~x"./generalDesc"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        fixed_line: ~x"./fixedLine"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        mobile: ~x"./mobile"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        toll_free: ~x"./tollFree"o |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        premium_rate: ~x"./premiumRate"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        shared_cost: ~x"./sharedCost"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        personal_number: ~x"./personalNumber"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        voip: ~x"./voip"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        pager: ~x"./pager"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        uan: ~x"./uan"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        #emergency: nil,
        voicemail: ~x"./voicemail"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        #short_code: nil,
        #standard_rate: nil,
        #carrier_specific: nil,
        no_international_dialing: ~x"./noInternationalDialling"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        id: ~x"./@id"s,
        country_code: ~x"./@countryCode"i,
        international_prefix: ~x"./@internationalPrefix"o |> transform_by(&normalize_string/1),
        preferred_international_prefix: ~x"./@preferredInternationalPrefix"o |> transform_by(&normalize_string/1),
        national_prefix: ~x"./@nationalPrefix"o |> transform_by(&normalize_string/1),
        preferred_extn_prefix: ~x"./@preferredExtnPrefix"o |> transform_by(&normalize_string/1),
        national_prefix_for_parsing: ~x"./nationalPrefixForParsing"o |> transform_by(&normalize_string/1),
        national_prefix_tranform_rule: ~x"./@nationalPrefixTransformRule"o |> transform_by(&normalize_string/1),
        #same_mobile_and_fixed_line_pattern: nil,
        available_formats: [
          ~x"./availableFormats/numberFormat"el,
          number_format: ~x"."e |> transform_by(&NumberFormat.from_xpath_node/1)
          #intl_number_format: nil,
        ],
        main_country_for_code: ~x"./@mainCountryForCode"o |> transform_by(&normalize_boolean/1),
        leading_digits: ~x"./@leadingDigits"o |> transform_by(&normalize_string/1),
        leading_zero_possible: ~x"./leadingZeroPossible"o |> transform_by(&normalize_boolean/1),
        mobile_number_portable_region: ~x"./@mobileNumberPortableRegion"o |> transform_by(&normalize_boolean/1)
      )
    struct(%PhoneMetadata{}, kwlist)
  end

  defp normalize_string(nil), do: nil
  defp normalize_string(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
  end

  defp normalize_boolean(nil), do: nil
  defp normalize_boolean(true_char_list) when is_list(true_char_list) and length(true_char_list) == 4, do: true

  @same_mobile_and_fixed_line_pattern_default false
  def get_same_mobile_and_fixed_line_pattern_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.same_mobile_and_fixed_line_pattern) do
      @same_mobile_and_fixed_line_pattern_default
    else
      phone_metadata.same_mobile_and_fixed_line_pattern
    end
  end

  @main_country_for_code_default false
  def get_main_country_for_code_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.main_country_for_code) do
      @main_country_for_code_default
    else
      phone_metadata.main_country_for_code
    end
  end

  @leading_zero_possible_default false
  def get_leading_zero_possible_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.leading_zero_possible) do
      @leading_zero_possible_default
    else
      phone_metadata.leading_zero_possible
    end
  end

  @mobile_number_portable_region_default false
  def get_mobile_number_portable_region_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.mobile_number_portable_region) do
      @mobile_number_portable_region_default
    else
      phone_metadata.mobile_number_portable_region
    end
  end
end

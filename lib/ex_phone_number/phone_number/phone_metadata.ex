defmodule ExPhoneNumber.PhoneNumber.PhoneMetadata do
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
            shoft_code: nil,                         # %PhoneNumberDescription{}
            standard_rate: nil,                      # %PhoneNumberDescription{}
            carrier_specific: nil                    # %PhoneNumberDescription{}
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

  alias ExPhoneNumber.PhoneNumber.PhoneMetadata

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

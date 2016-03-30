defmodule ExPhoneNumber.Validation do
  import ExPhoneNumber.Util
  alias ExPhoneNumber.Constant.ErrorMessage
  alias ExPhoneNumber.Constant.Pattern
  alias ExPhoneNumber.Constant.Value
  alias ExPhoneNumber.Constant.PhoneNumberType
  alias ExPhoneNumber.Constant.ValidationResult
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.PhoneNumber

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Value.max_input_string_length do
      {:error, ErrorMessage.too_long()}
    else
      {:ok, number_to_parse}
    end
  end

  def is_viable_phone_number?(phone_number) do
    cond do
      String.length(phone_number) < Value.min_length_for_nsn ->
        false
      true ->
        matches_entirely?(Pattern.valid_phone_number_pattern, phone_number)
    end
  end

  def is_valid_number?(%PhoneNumber{} = number) do
    region_code = Metadata.get_region_code_for_number(number)
    is_valid_number_for_region?(number, region_code)
  end

  def is_valid_number_for_region?(%PhoneNumber{} = number, nil), do: false
  def is_valid_number_for_region?(%PhoneNumber{} = number, region_code) when is_binary(region_code) do
    metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
    is_invalid_code = Value.region_code_for_non_geo_entity != region_code and number.country_code != Metadata.get_country_code_for_valid_region(region_code)
    if is_nil(metadata) or is_invalid_code do
      false
    else
      national_significant_number = PhoneNumber.get_national_significant_number(number)
      get_number_type_helper(national_significant_number, metadata) != PhoneNumberType.unknown
    end
  end

  def is_number_geographical?(%PhoneNumber{} = phone_number) do
    number_type = get_number_type(phone_number)
    number_type == PhoneNumberType.fixed_line or number_type == PhoneNumberType.fixed_line_or_mobile
  end

  def get_number_type(%PhoneNumber{} = phone_number) do
    region_code = Metadata.get_region_code_for_number(phone_number)
    metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
    unless metadata do
      PhoneNumberType.unknown
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)
      get_number_type_helper(national_significant_number, metadata)
    end
  end

  def get_number_type_helper(national_number, metadata = %PhoneMetadata{}) do
    cond do
      not is_number_matching_description?(national_number, metadata.general) -> PhoneNumberType.unknown
      is_number_matching_description?(national_number, metadata.premium_rate) -> PhoneNumberType.premium_rate
      is_number_matching_description?(national_number, metadata.toll_free) -> PhoneNumberType.toll_free
      is_number_matching_description?(national_number, metadata.shared_cost) -> PhoneNumberType.shared_cost
      is_number_matching_description?(national_number, metadata.voip) -> PhoneNumberType.voip
      is_number_matching_description?(national_number, metadata.personal_number) -> PhoneNumberType.personal_number
      is_number_matching_description?(national_number, metadata.pager) -> PhoneNumberType.pager
      is_number_matching_description?(national_number, metadata.uan) -> PhoneNumberType.uan
      is_number_matching_description?(national_number, metadata.voicemail) -> PhoneNumberType.voicemail
      is_number_matching_description?(national_number, metadata.fixed_line) ->
        if metadata.same_mobile_and_fixed_line_pattern do
          PhoneNumberType.fixed_line_or_mobile
        else
          if is_number_matching_description?(national_number, metadata.mobile) do
            PhoneNumberType.fixed_line_or_mobile
          else
            PhoneNumberType.fixed_line
          end
        end
      is_number_matching_description?(national_number, metadata.mobile) -> PhoneNumberType.mobile
      true -> PhoneNumberType.unknown
    end
  end

  def get_number_description_by_type(%PhoneMetadata{} = metadata, type) do
    cond do
      type == PhoneNumberType.premium_rate -> metadata.premium_rate
      type == PhoneNumberType.toll_free -> metadata.toll_free
      type == PhoneNumberType.mobile -> metadata.mobile
      type == PhoneNumberType.fixed_line -> metadata.fixed_line
      type == PhoneNumberType.fixed_line_or_mobile -> metadata.fixed_line
      type == PhoneNumberType.shared_cost -> metadata.shared_cost
      type == PhoneNumberType.voip -> metadata.voip
      type == PhoneNumberType.personal_number -> metadata.personal_number
      type == PhoneNumberType.pager -> metadata.pager
      type == PhoneNumberType.uan -> metadata.uan
      type == PhoneNumberType.voicemail -> metadata.voicemail
      true -> metadata.general
    end
  end

  def test_number_length_against_pattern(pattern, number) do
    if matches_entirely?(pattern, number) do
      ValidationResult.is_possible
    else
      case Regex.run(pattern, number, return: :index) do
        [{index, match_length} | tail] -> if index==0, do: ValidationResult.too_long, else: ValidationResult.too_short
        nil -> ValidationResult.too_short
      end
    end
  end
end

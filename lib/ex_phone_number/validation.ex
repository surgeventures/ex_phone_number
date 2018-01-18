defmodule ExPhoneNumber.Validation do
  import ExPhoneNumber.Utilities
  use ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.ErrorMessages
  alias ExPhoneNumber.Constants.Patterns
  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.ValidationResults
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  def get_number_description_by_type(%PhoneMetadata{} = metadata, type) do
    cond do
      type == PhoneNumberTypes.premium_rate -> metadata.premium_rate
      type == PhoneNumberTypes.toll_free -> metadata.toll_free
      type == PhoneNumberTypes.mobile -> metadata.mobile
      type == PhoneNumberTypes.fixed_line -> metadata.fixed_line
      type == PhoneNumberTypes.fixed_line_or_mobile -> metadata.fixed_line
      type == PhoneNumberTypes.shared_cost -> metadata.shared_cost
      type == PhoneNumberTypes.voip -> metadata.voip
      type == PhoneNumberTypes.personal_number -> metadata.personal_number
      type == PhoneNumberTypes.pager -> metadata.pager
      type == PhoneNumberTypes.uan -> metadata.uan
      type == PhoneNumberTypes.voicemail -> metadata.voicemail
      true -> metadata.general
    end
  end

  def get_number_type(%PhoneNumber{} = phone_number) do
    region_code = Metadata.get_region_code_for_number(phone_number)
    metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
    if metadata == nil do
      PhoneNumberTypes.unknown
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)
      get_number_type_helper(national_significant_number, metadata)
    end
  end

  def get_number_type_helper(national_number, metadata = %PhoneMetadata{}) do
    cond do
      not is_number_matching_description?(national_number, metadata.general) -> PhoneNumberTypes.unknown
      is_number_matching_description?(national_number, metadata.premium_rate) -> PhoneNumberTypes.premium_rate
      is_number_matching_description?(national_number, metadata.toll_free) -> PhoneNumberTypes.toll_free
      is_number_matching_description?(national_number, metadata.shared_cost) -> PhoneNumberTypes.shared_cost
      is_number_matching_description?(national_number, metadata.voip) -> PhoneNumberTypes.voip
      is_number_matching_description?(national_number, metadata.personal_number) -> PhoneNumberTypes.personal_number
      is_number_matching_description?(national_number, metadata.pager) -> PhoneNumberTypes.pager
      is_number_matching_description?(national_number, metadata.uan) -> PhoneNumberTypes.uan
      is_number_matching_description?(national_number, metadata.voicemail) -> PhoneNumberTypes.voicemail
      is_number_matching_description?(national_number, metadata.fixed_line) ->
        if metadata.same_mobile_and_fixed_line_pattern do
          PhoneNumberTypes.fixed_line_or_mobile
        else
          if is_number_matching_description?(national_number, metadata.mobile) do
            PhoneNumberTypes.fixed_line_or_mobile
          else
            PhoneNumberTypes.fixed_line
          end
        end
      is_number_matching_description?(national_number, metadata.mobile) -> PhoneNumberTypes.mobile
      true -> PhoneNumberTypes.unknown
    end
  end

  def is_number_geographical?(%PhoneNumber{} = phone_number) do
    number_type = get_number_type(phone_number)
    number_type == PhoneNumberTypes.fixed_line or number_type == PhoneNumberTypes.fixed_line_or_mobile
  end

  def is_possible_number?(%PhoneNumber{} = number) do
    result = is_possible_number_with_reason(number)
    result == ValidationResults.is_possible || result == ValidationResults.is_possible_local_only
  end

  # def is_possible_number_with_reason(%PhoneNumber{} = number) do
  #   if not Metadata.is_valid_country_code?(number.country_code) do
  #     ValidationResults.invalid_country_code
  #   else
  #     region_code = Metadata.get_region_code_for_country_code(number.country_code)
  #     metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
  #     national_number = PhoneNumber.get_national_significant_number(number)
  #     test_number_length_against_pattern(metadata.general.possible_number_pattern, national_number)
  #   end
  # end

  #  Check whether a phone number is a possible number. It provides a more lenient check than
  #  is_valid_number? in the following sense:
  #
  #    It only checks the length of phone numbers. In particular, it doesn't check starting
  #    digits of the number.
  #
  #    It doesn't attempt to figure out the type of the number, but uses general rules which
  #    applies to all types of phone numbers in a region. Therefore, it is much faster than
  #    isValidNumber.
  #
  #    For some numbers (particularly fixed-line), many regions have the concept of area code,
  #    which together with subscriber number constitute the national significant number. It is
  #    sometimes okay to dial only the subscriber number when dialing in the same area. This
  #    function will return IS_POSSIBLE_LOCAL_ONLY if the subscriber-number-only version is
  #    passed in. On the other hand, because isValidNumber validates using information on both
  #    starting digits (for fixed line numbers, that would most likely be area codes) and
  #    length (obviously includes the length of area codes for fixed line numbers), it will
  #    return false for the subscriber-number-only version.
  #
  # `number`  the number that needs to be checked
  # return    a validation result that indicates whether the number is possible
  def is_possible_number_with_reason(%PhoneNumber{} = number) do
    is_possible_number_for_type_with_reason(number, PhoneNumberTypes.unknown())
  end

  # Convenience wrapper around is_possible_number_for_type_with_reason. Instead of returning the
  # reason for failure, this method returns true if the number is either a possible fully-qualified
  # number (containing the area code and country code), or if the number could be a possible local
  # number (with a country code, but missing an area code). Local numbers are considered possible
  # if they could be possibly dialled in this format: if the area code is needed for a call to
  # connect, the number is not considered possible without it.
  #
  # `number`  the number that needs to be checked
  # `type`    the type we are interested in
  #
  # `return`  true if the number is possible for this particular type
  defp is_possible_number_for_type(%PhoneNumber{} = number, type) do
    result = is_possible_number_for_type_with_reason(number, type)

    result == ValidationResults.is_possible || result == ValidationResults.is_possible_local_only
  end

  defp is_possible_number_for_type_with_reason(%PhoneNumber{} = number, type) do
    national_number = PhoneNumber.get_national_significant_number(number)
    country_code = number.country_code

    # Note: For regions that share a country calling code, like NANPA numbers, we just use the
    # rules from the default region (US in this case) since the getRegionCodeForNumber will not
    # work if the number is possible but not valid. There is in fact one country calling code (290)
    # where the possible number pattern differs between various regions (Saint Helena and Tristan
    # da Cuñha), but this is handled by putting all possible lengths for any country with this
    # country calling code in the metadata for the default region in this case.
    if !has_valid_country_code?(country_code) do
      ValidationResults.invalid_country_code
    else
      region_code = Metadata.get_region_code_for_country_code(country_code)
      # Metadata cannot be null because the country calling code is valid.
      metadata = Metadata.get_for_region_code_or_calling_code(country_code, region_code)
      test_number_length(national_number, metadata, type)
    end
  end

  defp has_valid_country_code?(country_code) do
    unknown_region_code = Values.unknown_region

    case Metadata.get_region_code_for_country_code(country_code) do
      ^unknown_region_code -> false
      false                -> false
      _                    -> true
    end
  end

  def is_shorter_than_possible_normal_number?(metadata, number) do
    test_number_length_against_pattern(metadata.general.possible_number_pattern, number) == ValidationResults.too_short
  end

  def is_valid_number?(%PhoneNumber{} = number) do
    region_code = Metadata.get_region_code_for_number(number)
    is_valid_number_for_region?(number, region_code)
  end

  def is_valid_number_for_region?(%PhoneNumber{} = _number, nil), do: false
  def is_valid_number_for_region?(%PhoneNumber{} = number, region_code) when is_binary(region_code) do
    metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
    is_invalid_code = Values.region_code_for_non_geo_entity != region_code and number.country_code != Metadata.get_country_code_for_valid_region(region_code)
    if is_nil(metadata) or is_invalid_code do
      false
    else
      national_significant_number = PhoneNumber.get_national_significant_number(number)
      get_number_type_helper(national_significant_number, metadata) != PhoneNumberTypes.unknown
    end
  end

  def is_viable_phone_number?(phone_number) do
    if String.length(phone_number) < Values.min_length_for_nsn do
      false
    else
      matches_entirely?(phone_number, Patterns.valid_phone_number_pattern, false)
    end
  end

  def test_number_length_against_pattern(pattern, number) do
    if matches_entirely?(number, pattern, false) do
      ValidationResults.is_possible
    else
      case Regex.run(pattern, number, return: :index) do
        [{index, _match_length} | _tail] -> if index == 0, do: ValidationResults.too_long, else: ValidationResults.too_short
        nil -> ValidationResults.too_short
      end
    end
  end

  def test_number_length(national_number, metadata, phone_number_type \\ :unknown) do
    type_description = get_number_description_by_type(metadata, phone_number_type)

    {possible_lengths, local_lengths} = type_description
                                        |> get_lengths_for_type(metadata)
                                        |> maybe_merge_mobile_possible_lengths(phone_number_type, national_number, metadata)

    actual_length = String.length(national_number)
    minimum_length = List.first(possible_lengths)

    cond do
      is_nil(type_description)                    -> ValidationResults.invalid_length
      # This is safe because there is never an overlap beween the possible lengths and the local-only
      # lengths; this is checked at build time.
      actual_length in local_lengths              -> ValidationResults.is_possible_local_only
      minimum_length == actual_length             -> ValidationResults.is_possible
      minimum_length > actual_length              -> ValidationResults.too_short
      List.last(possible_lengths) < actual_length -> ValidationResults.too_long
      actual_length in possible_lengths           -> ValidationResults.is_possible
      true                                        -> ValidationResults.invalid_length
    end
  end

  defp maybe_merge_mobile_possible_lengths({possible_lengths, local_lengths}, @fixed_line_or_mobile, national_number, metadata) do
    type_description = get_number_description_by_type(metadata, @fixed_line)

    if not description_has_possible_number_data?(type_description) do
      # The rare case has been encountered where no fixedLine data is available (true for some
      # non-geographical entities), so we just check mobile.
      test_number_length(national_number, metadata, @mobile)
    else
      mobile_description = get_number_description_by_type(metadata, @mobile)

      if description_has_possible_number_data?(mobile_description) do
        # Merge the mobile data in if there was any. We have to make a copy to do this.
        # Note that when adding the possible lengths from mobile, we have to again check they
        # aren't empty since if they are this indicates they are the same as the general desc and
        # should be obtained from there.
        possible_lengths = if length(mobile_description.possible_lengths) == 0 do
                             metadata.general.possible_lengths ++ possible_lengths
                           else
                             mobile_description.possible_lengths ++ possible_lengths
                           end

        # The current list is sorted; we need to merge in the new list and re-sort (duplicates
        # are okay). Sorting isn't so expensive because the lists are very small.
        possible_lengths = Enum.sort(possible_lengths)

        local_lengths = if length(local_lengths) == 0 do
                          mobile_description.possible_length_local_only
                        else
                          Enum.sort(mobile_description.possible_lengths_local_only ++ local_lengths)
                        end

        {possible_lengths, local_lengths}
      else
        {possible_lengths, local_lengths}
      end
    end
  end
  defp maybe_merge_mobile_possible_lengths({possible_lengths, local_lengths}, _phone_number_type, _national_number, _metadata) do
    {possible_lengths, local_lengths}
  end

  defp description_has_possible_number_data?(%{possible_lengths: possible_lengths}) do
    length(possible_lengths) != 1 or List.first(possible_lengths) != -1
  end
  defp description_has_possible_number_data?(_description), do: false

  defp get_lengths_for_type(nil, metadata) do
    {metadata.general.possible_lengths, []}
  end
  defp get_lengths_for_type(type_description, metadata) do
    # There should always be "possible_lengths" set for every element. This is declared in the XML
    # schema which is verified by PhoneNumberMetadataSchemaTest.
    # For size efficiency, where a sub-description (e.g. fixed-line) has the same possibleLengths
    # as the parent, this is missing, so we fall back to the general desc (where no numbers of the
    # type exist at all, there is one possible length (-1) which is guaranteed not to match the
    # length of any real phone number).
    possible_lengths = if length(type_description.possible_lengths) == 0, do: metadata.general.possible_lengths, else: type_description.possible_lengths

    {possible_lengths, type_description.possible_lengths_local_only}
  end

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Values.max_input_string_length do
      {:error, ErrorMessages.too_long()}
    else
      {:ok, number_to_parse}
    end
  end
end

defmodule ExPhoneNumber.PhoneNumberUtilSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.PhoneNumberUtil
  import ExPhoneNumber.PhoneNumberUtil
  alias PhoneNumberFixture
  alias ExPhoneNumber.Constant.ValidationResult


  describe ".is_possible_number?/1" do
    context "US number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.us_number)
      end
    end

    context "US local number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.us_local_number)
      end
    end

    context "GB number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.gb_number)
      end
    end

    context "International Toll Free" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.international_toll_free)
      end
    end
  end

  describe ".is_possible_number_with_reason?/1" do
    context "US number" do
      it "should return correct value" do
        assert ValidationResult.is_possible == is_possible_number_with_reason?(PhoneNumberFixture.us_number)
      end
    end

    context "US local number" do
      it "should return correct value" do
        assert ValidationResult.is_possible == is_possible_number_with_reason?(PhoneNumberFixture.us_number)
      end
    end

    context "US long number" do
      it "should return correct value" do
        assert ValidationResult.too_long == is_possible_number_with_reason?(PhoneNumberFixture.us_long_number)
      end
    end

    context "Invalid country code" do
      it "should return correct value" do
        assert ValidationResult.invalid_country_code == is_possible_number_with_reason?(PhoneNumberFixture.unknown_country_code2)
      end
    end

    context "US short number" do
      it "should return correct value" do
        assert ValidationResult.too_short == is_possible_number_with_reason?(PhoneNumberFixture.nanpa_short_number)
      end
    end

    context "SG number 2" do
      it "should return correct value" do
        assert ValidationResult.is_possible == is_possible_number_with_reason?(PhoneNumberFixture.sg_number2)
      end
    end

    context "International Toll Free long number" do
      it "should return correct value" do
        assert ValidationResult.too_long == is_possible_number_with_reason?(PhoneNumberFixture.international_toll_free_too_long)
      end
    end
  end
end

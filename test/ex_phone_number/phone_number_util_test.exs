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

    context "NANPA short number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.nanpa_short_number)
      end
    end

    context "US long number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.us_long_number)
      end
    end

    context "GB short number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.gb_short_number)
      end
    end

    context "International Toll Free too long" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.international_toll_free_too_long)
      end
    end
  end

  xdescribe ".is_possible_number?/2" do
    context "US region" do
      it "should return true #1" do
        assert is_possible_number?("+1 650 253 0000", RegionCodeFixture.us)
      end

      it "should return true #2" do
        assert is_possible_number?("+1 650 GOO OGLE", RegionCodeFixture.us)
      end

      it "should return true #3" do
        assert is_possible_number?("(650) 253-0000", RegionCodeFixture.us)
      end

      it "should return true #4" do
        assert is_possible_number?("253-0000", RegionCodeFixture.us)
      end

      it "should return false #1" do
        refute is_possible_number?("+1 650 253 00000", RegionCodeFixture.us)
      end

      it "should return false #2" do
        refute is_possible_number?("(650) 253-00000", RegionCodeFixture.us)
      end

      it "should return false #3" do
        refute is_possible_number?("I want a Pizza", RegionCodeFixture.us)
      end

      it "should return false #4" do
        refute is_possible_number?("253-000", RegionCodeFixture.us)
      end
    end

    context "GB region" do
      it "should return true #1" do
        assert is_possible_number?("+1 650 253 0000", RegionCodeFixture.gb)
      end

      it "should return true #2" do
        assert is_possible_number?("+44 20 7031 3000", RegionCodeFixture.gb)
      end

      it "should return true #3" do
        assert is_possible_number?("(020) 7031 3000", RegionCodeFixture.gb)
      end

      it "should return true #4" do
        assert is_possible_number?("7031 3000", RegionCodeFixture.gb)
      end

      it "should return false #1" do
        refute is_possible_number?("1 3000", RegionCodeFixture.gb)
      end

      it "should return false #2" do
        refute is_possible_number?("+44 300", RegionCodeFixture.gb)
      end

    end

    context "NZ region" do
      it "should return true #1" do
        assert is_possible_number?("3331 6005", RegionCodeFixture.nz)
      end
    end

    context "UN001 region" do
      it "should return true #1" do
        assert is_possible_number?("+800 1234 5678", RegionCodeFixture.un001)
      end

      it "should return false #1" do
        refute is_possible_number?("+800 1234 5678 9", RegionCodeFixture.un001)
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

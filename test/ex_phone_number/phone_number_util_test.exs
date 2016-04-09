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

  describe ".is_possible_number?/2" do
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

  describe ".parse/2" do
    context "NZ number" do
      it "should return correct value #1" do
        {result, phone_number} = parse("033316005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("33316005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("03-331 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("03 331 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("tel:03-331-6005;phone-context=+64", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("tel:331-6005;phone-context=+64-3", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #7" do
        {result, phone_number} = parse("tel:331-6005;phone-context=+64-3", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #8" do
        {result, phone_number} = parse("My number is tel:03-331-6005;phone-context=+64", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #9" do
        {result, phone_number} = parse("tel:03-331-6005;phone-context=+64;a=%A1", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #10" do
        {result, phone_number} = parse("tel:03-331-6005;isub=12345;phone-context=+64", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #11" do
        {result, phone_number} = parse("tel:+64-3-331-6005;isub=12345", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #12" do
        {result, phone_number} = parse("03-331-6005;phone-context=+64", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #13" do
        {result, phone_number} = parse("0064 3 331 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #14" do
        {result, phone_number} = parse("01164 3 331 6005", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #15" do
        {result, phone_number} = parse("+64 3 331 6005", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #16" do
        {result, phone_number} = parse("+01164 3 331 6005", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #17" do
        {result, phone_number} = parse("+0064 3 331 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end

      it "should return correct value #18" do
        {result, phone_number} = parse("+ 00 64 3 331 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number == phone_number
      end
    end

    context "NZ number3" do
      it "should return correct value" do
        {result, phone_number} = parse("64(0)64123456", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_number3 == phone_number
      end
    end

    context "NZ short number" do
      it "should return correct value" do
        {result, phone_number} = parse("12", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_short_number == phone_number
      end
    end

    context "DE number" do
      it "should return correct value" do
        {result, phone_number} = parse("301/23456", RegionCodeFixture.de)
        assert :ok == result
        assert PhoneNumberFixture.de_number == phone_number
      end
    end

    context "JP star number" do
      it "should return correct value" do
        {result, phone_number} = parse("+81 *2345", RegionCodeFixture.jp)
        assert :ok == result
        assert PhoneNumberFixture.jp_star_number == phone_number
      end
    end

    context "US number2" do
      it "should return correct value" do
        {result, phone_number} = parse("123-456-7890", RegionCodeFixture.de)
        assert :ok == result
        assert PhoneNumberFixture.us_number2 == phone_number
      end
    end

    context "US local number" do
      it "should return correct value #1" do
        {result, phone_number} = parse("tel:253-0000;phone-context=www.google.com", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_local_number == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("tel:253-0000;isub=12345;phone-context=www.google.com", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_local_number == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("tel:2530000;isub=12345;phone-context=1-650", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_local_number == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("tel:2530000;isub=12345;phone-context=1234.com", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_local_number == phone_number
      end
    end

    context "Number with alpha chars" do
      it "should return correct value #1" do
        {result, phone_number} = parse("0800 DDA 005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_toll_free == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("0900 DDA 6005", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_premium == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("0900 332 6005a", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_premium == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("0900 332 600a5", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_premium == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("0900 332 600A5", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_premium == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("0900 a332 600A5", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.nz_premium == phone_number
      end
    end

    context "Number with international prefix" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+1 (650) 253-0000", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("011 800 1234 5678", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.international_toll_free == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("1-650-253-0000", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("0011-650-253-0000", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("0081-650-253-0000", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("0191-650-253-0000", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #7" do
        {result, phone_number} = parse("0~01-650-253-0000", RegionCodeFixture.pl)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #8" do
        {result, phone_number} = parse("++1 (650) 253-0000", RegionCodeFixture.pl)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end
    end

    context "Non Ascii" do
      it "should return correct value #1" do
        {result, phone_number} = parse("\uFF0B1 (650) 253-0000", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("1 (650) 253\u00AD-0000", RegionCodeFixture.us)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\uFF0D\uFF10\uFF10\uFF10\uFF10", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\u30FC\uFF10\uFF10\uFF10\uFF10", RegionCodeFixture.sg)
        assert :ok == result
        assert PhoneNumberFixture.us_number == phone_number
      end
    end

    context "With Leading Zero" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+39 02-36618 300", RegionCodeFixture.nz)
        assert :ok == result
        assert PhoneNumberFixture.it_number == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("02-36618 300", RegionCodeFixture.it)
        assert :ok == result
        assert PhoneNumberFixture.it_number == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("345 678 901", RegionCodeFixture.it)
        assert :ok == result
        assert PhoneNumberFixture.it_mobile == phone_number
      end
    end
  end
end

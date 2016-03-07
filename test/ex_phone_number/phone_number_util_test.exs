defmodule ExPhoneNumber.PhoneNumberUtilSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.PhoneNumberUtil
  alias ExPhoneNumber.PhoneNumberUtil

  describe ".validate_length" do
    context "length less or equal to @max_input_string_length" do
      subject do: "1234567890"
      it "returns {:ok, number}" do
        assert {:ok, _} = PhoneNumberUtil.validate_length(subject)
      end
    end

    context "length larger than `@max_input_string_length`" do
      subject do: "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x"
      it "returns {:error, message}" do
        assert {:error, _} = PhoneNumberUtil.validate_length(subject)
      end
    end
  end

  describe ".extract_possible_number" do
    context "removes preceding funky punctuation and letters" do
      it "should return the correct value" do
        assert "0800-345-600" == PhoneNumberUtil.extract_possible_number("Tel:0800-345-600")
        assert "0800 FOR PIZZA" == PhoneNumberUtil.extract_possible_number("Tel:0800 FOR PIZZA")
      end

      it "should not remove plus sign" do
        assert "+800-345-600" == PhoneNumberUtil.extract_possible_number("Tel:+800-345-600")
      end

      it "should recognise wide digits as possible start values" do
        assert "\uFF10\uFF12\uFF13" == PhoneNumberUtil.extract_possible_number("\uFF10\uFF12\uFF13")
      end

      it "should remove leading dashes" do
        assert "\uFF11\uFF12\uFF13" == PhoneNumberUtil.extract_possible_number("Num-\uFF11\uFF12\uFF13")
      end

      it "should remove leading parenthesis" do
        assert "650) 253-0000" == PhoneNumberUtil.extract_possible_number("(650) 253-0000")
      end
    end

    context "number not found" do
      it "should return empty string" do
        assert "" == PhoneNumberUtil.extract_possible_number("Num-....")
      end
    end

    context "removes trailing characters" do
      it "should remove trailing non-alpha-numeric chars" do
        assert "650) 253-0000" == PhoneNumberUtil.extract_possible_number("(650) 253-0000..- ..")
        assert "650) 253-0000" == PhoneNumberUtil.extract_possible_number("(650) 253-0000.")
      end

      it "should remove trailing RTL char" do
        assert "650) 253-0000" == PhoneNumberUtil.extract_possible_number("(650) 253-0000\u200F")
      end
    end
  end

  describe ".viable_phone_number?" do
    context "ascii chars" do
      it "should contain at least 2 chars" do
        refute PhoneNumberUtil.viable_phone_number?("1")
      end

      it "should allow only one or two digits before strange non-possible puntuaction" do
        refute PhoneNumberUtil.viable_phone_number?("1+1+1")
        refute PhoneNumberUtil.viable_phone_number?("80+0")
      end

      it "should allow two or more digits" do
        assert PhoneNumberUtil.viable_phone_number?("00")
        assert PhoneNumberUtil.viable_phone_number?("111")
      end

      it "should allow alpha numbers" do
        assert PhoneNumberUtil.viable_phone_number?("0800-4-pizza")
        assert PhoneNumberUtil.viable_phone_number?("0800-4-PIZZA")
      end

      it "should contain at least three digits before any alpha char" do
        refute PhoneNumberUtil.viable_phone_number?("08-PIZZA")
        refute PhoneNumberUtil.viable_phone_number?("8-PIZZA")
        refute PhoneNumberUtil.viable_phone_number?("12. March")
      end
    end

    context "non-ascii chars" do
      @tag :pending
      it "should allow only one or two digits before strange non-possible puntuaction" do
        assert PhoneNumberUtil.viable_phone_number?("1\u300034")
        refute PhoneNumberUtil.viable_phone_number?("1\u30003+4")
      end

      @tag :pending
      it "should allow unicode variants of starting chars" do
        assert PhoneNumberUtil.viable_phone_number?("\uFF081\uFF09\u30003456789")
      end

      @tag :pending
      it "should allow leading plus sign" do
        assert PhoneNumberUtil.viable_phone_number?("+1\uFF09\u30003456789")
      end
    end
  end
end

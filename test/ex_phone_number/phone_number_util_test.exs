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
end

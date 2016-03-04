defmodule ExPhoneNumber.PhoneNumberUtilSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.PhoneNumberUtil
  import ExPhoneNumber.PhoneNumberUtil
  alias ExPhoneNumber.PhoneNumberUtil

  describe "invalid phone_number" do
    context "length larger than `@max_input_string_length`" do
      subject do: "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x"
      it "returns {:error, :message}" do
        assert {:error, _} = PhoneNumberUtil.parse(subject, "")
      end
    end
  end
end

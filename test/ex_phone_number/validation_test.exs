defmodule ExPhoneNumber.ValidationSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.Validation
  import ExPhoneNumber.Validation

  describe ".validate_length" do
    context "length less or equal to Constant.Value.max_input_string_length" do
      subject do: "1234567890"
      it "returns {:ok, number}" do
        assert {:ok, _} = validate_length(subject)
      end
    end

    context "length larger than Constant.Value.max_input_string_length" do
      subject do: "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x"
      it "returns {:error, message}" do
        assert {:error, _} = validate_length(subject)
      end
    end
  end
end

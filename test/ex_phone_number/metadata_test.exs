defmodule ExPhoneNumber.MetadataSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.Metadata
  import ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata

  describe ".get_for_region_code" do
    context "US region_code" do
      subject do: "US"
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert "US" == metadata.id
      end

      it "returns valid country_code" do
        assert 1 == metadata.country_code
      end

      it "returns valid international_prefix" do
        assert "011" == metadata.international_prefix
      end

      it "returns valid has_national_prefix?" do
        assert PhoneMetadata.has_national_prefix?(metadata)
      end

      it "returns valid number_format length" do
        assert 2 == length(metadata.number_format)
      end

      it "returns valid number_format(1).pattern" do
        assert "(\\d{3})(\\d{3})(\\d{4})" == Enum.at(metadata.number_format, 1).pattern
      end

      it "returns valid number_format(1).format" do
        assert "$1 $2 $3" == Enum.at(metadata.number_format, 1).format
      end

      it "returns valid general.national_number_pattern" do
        assert "[13-689]\\d{9}|2[0-35-9]\\d{8}" == metadata.general.national_number_pattern
      end

      it "returns valid general.possible_number_pattern" do
        assert "\\d{7}(?:\\d{3})?" == metadata.general.possible_number_pattern
      end

      it "returns valid fixed_line" do
        assert metadata.general == metadata.fixed_line
      end

      it "returns valid toll_free.possible_number_pattern" do
        assert "\\d{10}" == metadata.toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern" do
        assert "900\\d{7}" == metadata.premium_rate.national_number_pattern
      end

      it "returns valid shared_cost.national_number_pattern" do
        assert "NA" == metadata.shared_cost.national_number_pattern
      end

      it "returns valid shared_cost.possible_number_pattern" do
        assert "NA" == metadata.shared_cost.possible_number_pattern
      end
    end

    context "DE region_code" do
      subject do: "DE"
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert "DE"  == metadata.id
      end

      it "returns valid country_code" do
        assert 49 == metadata.country_code
      end

      it "returns valid international_prefix" do
        assert "00" == metadata.international_prefix
      end

      it "returns valid national_prefix" do
        assert "0" == metadata.national_prefix
      end

      it "returns valid number_format length" do
        assert 6 == length(metadata.number_format)
      end

      it "returns valid number_format(5).leading_digits_pattern length" do
        assert 1 == length(Enum.at(metadata.number_format, 5).leading_digits_pattern)
      end

      it "returns valid number_format(5).leading_digits_pattern(0)" do
        assert "900" == Enum.at(Enum.at(metadata.number_format, 5).leading_digits_pattern, 0)
      end

      it "returns valid number_format(5).pattern" do
        assert "(\\d{3})(\\d{3,4})(\\d{4})" == Enum.at(metadata.number_format, 5).pattern
      end

      it "returns valid number_format(5).format" do
        assert "$1 $2 $3" ==  Enum.at(metadata.number_format, 5).format
      end

      it "returns valid fixed_line.national_number_pattern" do
        assert "(?:[24-6]\\d{2}|3[03-9]\\d|[789](?:[1-9]\\d|0[2-9]))\\d{1,8}" == metadata.fixed_line.national_number_pattern
      end

      it "returns valid fixed_line.possible_number_pattern" do
        assert "\\d{2,14}" == metadata.fixed_line.possible_number_pattern
      end

      it "returns valid fixed_line.example_number" do
        assert "30123456" == metadata.fixed_line.example_number
      end

      it "returns valid toll_free.possible_number_pattern" do
        assert "\\d{10}" == metadata.toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern" do
        assert "900([135]\\d{6}|9\\d{7})" == metadata.premium_rate.national_number_pattern
      end
    end

    context "AR region_code" do
      subject do: "AR"
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert "AR" == metadata.id
      end

      it "returns valid country_code" do
        assert 54 == metadata.country_code
      end

      it "returns valid international_prefix" do
        assert "00" == metadata.international_prefix
      end

      it "returns valid national_prefix" do
        assert "0" == metadata.national_prefix
      end

      it "returns valid national_prefix_for_parsing" do
        assert "0(?:(11|343|3715)15)?" == metadata.national_prefix_for_parsing
      end

      it "returns valid national_prefix_transform_rule" do
        assert "9$1" == metadata.national_prefix_transform_rule
      end

      it "returns valid number_format(2).format" do
        assert "$2 15 $3-$4" == Enum.at(metadata.number_format, 2).format
      end

      it "returns valid number_format(3).pattern" do
        assert "(9)(\\d{4})(\\d{2})(\\d{4})" == Enum.at(metadata.number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).pattern" do
        assert "(9)(\\d{4})(\\d{2})(\\d{4})" == Enum.at(metadata.intl_number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).format" do
        assert "$1 $2 $3 $4" == Enum.at(metadata.intl_number_format, 3).format
      end
    end

  end
end

defmodule ExPhoneNumber.MetadataSpec do
  use Pavlov.Case, async: true

  doctest ExPhoneNumber.Metadata
  import ExPhoneNumber.Metadata
  alias ExPhoneNumber.Constant.Value
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias PhoneNumberFixture
  alias RegionCodeFixture

  describe ".get_for_region_code/1" do
    context "US region_code" do
      subject do: RegionCodeFixture.us
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert RegionCodeFixture.us == metadata.id
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
        assert ~r/(\d{3})(\d{3})(\d{4})/ == Enum.at(metadata.number_format, 1).pattern
      end

      it "returns valid number_format(1).format" do
        assert "$1 $2 $3" == Enum.at(metadata.number_format, 1).format
      end

      it "returns valid general.national_number_pattern" do
        assert ~r/[13-689]\d{9}|2[0-35-9]\d{8}/ == metadata.general.national_number_pattern
      end

      it "returns valid general.possible_number_pattern" do
        assert ~r/\d{7}(?:\d{3})?/ == metadata.general.possible_number_pattern
      end

      it "returns valid fixed_line" do
        assert metadata.general == metadata.fixed_line
      end

      it "returns valid toll_free.possible_number_pattern" do
        assert ~r/\d{10}/ == metadata.toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern" do
        assert ~r/900\d{7}/ == metadata.premium_rate.national_number_pattern
      end

      it "returns valid shared_cost.national_number_pattern" do
        assert Value.description_default_pattern == metadata.shared_cost.national_number_pattern
      end

      it "returns valid shared_cost.possible_number_pattern" do
        assert Value.description_default_pattern == metadata.shared_cost.possible_number_pattern
      end
    end

    context "DE region_code" do
      subject do: RegionCodeFixture.de
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert RegionCodeFixture.de  == metadata.id
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
        assert ~r/900/ == Enum.at(Enum.at(metadata.number_format, 5).leading_digits_pattern, 0)
      end

      it "returns valid number_format(5).pattern" do
        assert ~r/(\d{3})(\d{3,4})(\d{4})/ == Enum.at(metadata.number_format, 5).pattern
      end

      it "returns valid number_format(5).format" do
        assert "$1 $2 $3" ==  Enum.at(metadata.number_format, 5).format
      end

      it "returns valid fixed_line.national_number_pattern" do
        assert ~r/(?:[24-6]\d{2}|3[03-9]\d|[789](?:[1-9]\d|0[2-9]))\d{1,8}/ == metadata.fixed_line.national_number_pattern
      end

      it "returns valid fixed_line.possible_number_pattern" do
        assert ~r/\d{2,14}/ == metadata.fixed_line.possible_number_pattern
      end

      it "returns valid fixed_line.example_number" do
        assert "30123456" == metadata.fixed_line.example_number
      end

      it "returns valid toll_free.possible_number_pattern" do
        assert ~r/\d{10}/ == metadata.toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern" do
        assert ~r/900([135]\d{6}|9\d{7})/ == metadata.premium_rate.national_number_pattern
      end
    end

    context "AR region_code" do
      subject do: "AR"
      let :metadata do
        ExPhoneNumber.Metadata.get_for_region_code(subject)
      end

      it "returns valid id" do
        assert RegionCodeFixture.ar == metadata.id
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
        assert ~r/(9)(\d{4})(\d{2})(\d{4})/ == Enum.at(metadata.number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).pattern" do
        assert ~r/(9)(\d{4})(\d{2})(\d{4})/ == Enum.at(metadata.intl_number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).format" do
        assert "$1 $2 $3 $4" == Enum.at(metadata.intl_number_format, 3).format
      end
    end
  end

  describe ".get_for_non_geographical_region/1" do
    context "800 calling code" do
      subject do: 800
      let :metadata do
        ExPhoneNumber.Metadata.get_for_non_geographical_region(subject)
      end

      it "returns valid id" do
        assert RegionCodeFixture.un001 == metadata.id
      end

      it "returns valid country_code" do
        assert 800 == metadata.country_code
      end

      it "returns valid number_format(0).format" do
        assert "$1 $2" == Enum.at(metadata.number_format, 0).format
      end

      it "returns valid number_format(0).pattern" do
        assert ~r/(\d{4})(\d{4})/ == Enum.at(metadata.number_format, 0).pattern
      end

      it "returns valid general.example_number" do
        assert "12345678" == metadata.general.example_number
      end

      it "returns valid toll_free.example_number" do
        assert "12345678" == metadata.toll_free.example_number
      end
    end
  end

  describe ".get_supported_regions/1" do
    context "get a list of supported regions" do
      it "should contain at least one element" do
        assert 0 < length(get_supported_regions)
      end
    end
  end

  describe ".is_supported_region?/1" do
    context "US" do
      it "returns true" do
        assert is_supported_region?(RegionCodeFixture.us)
      end
    end

    context "001" do
      it "returns false" do
        refute is_supported_region?(RegionCodeFixture.un001)
      end

      it "returns false for calling code" do
        refute Enum.any?(get_supported_regions, fn(region_code) -> region_code == "800" end)
      end
    end
  end

  describe ".get_supported_global_network_calling_codes/1" do
    context "get a list of supported global network calling codes" do
      it "contains at least one element" do
        assert 0 < length(get_supported_global_network_calling_codes)
      end
    end

    context "test all the calling codes" do
      it "contains all the calling codes" do
        assert Enum.all?(get_supported_global_network_calling_codes, fn(calling_code) -> get_region_code_for_country_code(calling_code) == RegionCodeFixture.un001 end)
      end
    end
  end

  describe ".is_supported_global_network_calling_code?/1" do
    context "US" do
      it "returns false" do
        refute is_supported_global_network_calling_code?(1)
      end
    end

    context "800" do
      it "returns true" do
        assert is_supported_global_network_calling_code?(800)
      end
    end
  end

  describe ".get_region_code_for_country_code/1" do
    context "1" do
      it "returns correct value" do
        assert RegionCodeFixture.us == get_region_code_for_country_code(1)
      end
    end

    context "44" do
      it "returns correct value" do
        assert RegionCodeFixture.gb == get_region_code_for_country_code(44)
      end
    end

    context "49" do
      it "returns correct value" do
        assert RegionCodeFixture.de == get_region_code_for_country_code(49)
      end
    end

    context "800" do
      it "returns correct value" do
        assert RegionCodeFixture.un001 == get_region_code_for_country_code(800)
      end
    end

    context "979" do
      it "returns correct value" do
        assert RegionCodeFixture.un001 == get_region_code_for_country_code(979)
      end
    end
  end

  describe ".get_region_codes_for_country_code/1" do
    context "1" do
      it "should contains US BS" do
        list = get_region_codes_for_country_code(1)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.us))
        assert Enum.any?(list, &(&1 == RegionCodeFixture.bs))
      end
    end

    context "44" do
      it "should contains GB" do
        list = get_region_codes_for_country_code(44)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.gb))
      end
    end

    context "49" do
      it "should contains DE" do
        list = get_region_codes_for_country_code(49)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.de))
      end
    end

    context "800" do
      it "should contains 001" do
        list = get_region_codes_for_country_code(800)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.un001))
      end
    end

    context "-1" do
      it "should be empty" do
        assert 0 == length(get_region_codes_for_country_code(-1))
      end
    end
  end

  describe ".get_country_code_for_region_code/1" do
    context "US" do
      it "returns correct value" do
        assert 1 == get_country_code_for_region_code RegionCodeFixture.us
      end
    end

    context "NZ" do
      it "returns correct value" do
        assert 64 == get_country_code_for_region_code RegionCodeFixture.nz
      end
    end

    context "nil" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code nil
      end
    end

    context "ZZ" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code RegionCodeFixture.zz
      end
    end

    context "001" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code RegionCodeFixture.un001
      end
    end

    context "CS" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code "CS"
      end
    end
  end

  describe ".get_region_code_for_number/1" do
    context "BS" do
      it "return correct value" do
        assert RegionCodeFixture.bs == get_region_code_for_number(PhoneNumberFixture.bs_number)
      end
    end

    context "YT" do
      it "return correct value" do
        assert RegionCodeFixture.yt == get_region_code_for_number(PhoneNumberFixture.re_number_invalid)
      end
    end

    context "US" do
      it "return correct value" do
        assert RegionCodeFixture.us == get_region_code_for_number(PhoneNumberFixture.us_number)
      end
    end

    context "GB" do
      it "return correct value" do
        assert RegionCodeFixture.gb == get_region_code_for_number(PhoneNumberFixture.gb_mobile)
      end
    end

    context "001" do
      it "return correct value for International Toll Free" do
        assert RegionCodeFixture.un001 == get_region_code_for_number(PhoneNumberFixture.international_toll_free)
      end

      it "return correct value for Universal Premium Rate" do
        assert RegionCodeFixture.un001 == get_region_code_for_number(PhoneNumberFixture.universal_premium_rate)
      end
    end
  end
end

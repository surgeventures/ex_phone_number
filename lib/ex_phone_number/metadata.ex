defmodule ExPhoneNumber.Metadata do
  import SweetXml
  import ExPhoneNumber.Normalization
  alias ExPhoneNumber.Metadata.PhoneMetadata

  @resources_dir "./resources"
  @xml_file Application.fetch_env!(:ex_phone_number, :metadata_file)
  @document_path Path.join([@resources_dir, @xml_file])
  @external_resource @document_path

  document = File.read!(@document_path)
  metadata_collection =
    document |> xpath(
      ~x"//phoneNumberMetadata/territories/territory"el,
      territory: ~x"." |> transform_by(&PhoneMetadata.from_xpath_node/1)
      )

  Module.register_attribute(__MODULE__, :list_region_code_to_metadata, accumulate: true)
  Module.register_attribute(__MODULE__, :list_country_code_to_region_code, accumulate: true)

  for metadata <- metadata_collection do
    phone_metadata = PhoneMetadata.put_default_values(Map.get(metadata, :territory))

    region = Map.get(phone_metadata, :id)
    region_atom = String.to_atom(region)
    Module.put_attribute(__MODULE__, :list_region_code_to_metadata, {region_atom, phone_metadata})

    country_code = Map.get(phone_metadata, :country_code)
    country_code_atom = String.to_atom(Integer.to_string(country_code))
    Module.put_attribute(__MODULE__, :list_country_code_to_region_code, {country_code_atom, region})
  end

  def get_for_non_geographical_region(calling_code) when is_number(calling_code) do
    region_code = get_region_code_for_country_code(calling_code)
    get_for_region_code(region_code, calling_code)
  end

  def get_for_region_code(region_code) when is_binary(region_code) do
    Keyword.get(list_region_code_to_metadata, String.to_atom(String.upcase(region_code)))
  end
  def get_for_region_code(_), do: nil

  def get_for_region_code(region_code, country_code) when is_binary(region_code) and is_number(country_code) do
    possible_metadatas = Keyword.get_values(list_region_code_to_metadata, String.to_atom(String.upcase(region_code)))
    Enum.find(possible_metadatas, fn(metadata) -> country_code == metadata.country_code end)
  end

  def get_region_code_for_country_code(country_code) when is_number(country_code) do
    possible_region_codes = get_region_codes_for_country_code(country_code)
    possible_metadatas = Enum.map(possible_region_codes, fn(region_code) -> get_for_region_code(region_code) end)
    metadata = Enum.find(possible_metadatas, fn(metadata) -> metadata.main_country_for_code end)
    if is_nil(metadata) do
      List.last(possible_metadatas).id
    else
      metadata.id
    end
  end
  def get_region_code_for_country_code(_), do: nil

  def get_region_codes_for_country_code(country_code) when is_number(country_code) do
    Keyword.get_values(list_country_code_to_region_code, String.to_atom(Integer.to_string(country_code)))
  end

  def list_region_code_to_metadata, do: @list_region_code_to_metadata

  def list_country_code_to_region_code, do: @list_country_code_to_region_code

  def valid_region_code?(region_code) when is_binary(region_code) do
    unless Integer.parse(region_code) == :error do
      false
    else
      Keyword.has_key?(list_region_code_to_metadata, String.to_atom(String.upcase(region_code)))
    end
  end
  def valid_region_code?(_), do: nil

  def get_country_code_for_region_code(region_code) do
    if valid_region_code?(region_code) do
      get_for_region_code(region_code).country_code
    else
      0
    end
  end

  def get_supported_regions() do
    Enum.filter(list_region_code_to_metadata, fn({_region_code, metadata}) -> Integer.parse(metadata.id) == :error end)
  end

  def is_supported_region?(region_code) when is_binary(region_code) do
    Enum.any?(get_supported_regions, fn({_, metadata}) -> metadata.id == region_code end)
  end

  def get_supported_global_network_calling_codes() do
    Enum.filter(list_region_code_to_metadata, fn({_region_code, metadata}) -> Integer.parse(metadata.id) != :error end)
  end

  def is_supported_global_network_calling_code?(calling_code) when is_number(calling_code) do
    Enum.any?(get_supported_global_network_calling_codes, fn({_, metadata}) -> metadata.country_code == calling_code end)
  end

  def is_supported_country_calling_code?(calling_code) when is_number(calling_code) do
    Enum.any?(list_country_code_to_region_code, fn({_, metadata}) -> metadata.country_code == calling_code end)
  end

  def get_for_region_code_or_calling_code(calling_code, region_code) do
    unless is_nil_or_empty?(region_code) do
      get_for_region_code(region_code)
    else
      get_for_non_geographical_region(calling_code)
    end
  end
end

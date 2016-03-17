defmodule ExPhoneNumber.Metadata do
  import SweetXml
  alias ExPhoneNumber.Metadata.PhoneMetadata

  @resources_dir "./resources"
  @xml_file "PhoneNumberMetadata.xml"
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
    phone_metadata = Map.get(metadata, :territory)

    region = Map.get(phone_metadata, :id)
    region_atom = String.to_atom(region)
    Module.put_attribute(__MODULE__, :list_region_code_to_metadata, {region_atom, phone_metadata})
    def get_for_region_code(unquote(region)), do: Keyword.get_values(list_region_code_to_metadata(),String.to_atom(unquote(region)))

    country_code = Map.get(phone_metadata, :country_code)
    country_code_atom = String.to_atom(Integer.to_string(country_code))
    Module.put_attribute(__MODULE__, :list_country_code_to_region_code, {country_code_atom, region})
    def get_region_code_for_country_code(unquote(country_code)), do: Keyword.get_values(list_country_code_to_region_code(),String.to_atom(Integer.to_string(unquote(country_code))))
  end

  def list_region_code_to_metadata, do: @list_region_code_to_metadata

  def list_country_code_to_region_code, do: @list_country_code_to_region_code
end

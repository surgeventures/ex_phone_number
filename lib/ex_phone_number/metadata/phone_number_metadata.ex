defmodule ExPhoneNumber.Metadata.PhoneNumberMetadata do
  import ExPhoneNumber.Metadata
  import SweetXml
  alias ExPhoneNumber.Metadata.PhoneMetadata

  @resources_dir "./resources"
  @xml_file "PhoneNumberMetadata.xml"
  @document_path Path.join([@resources_dir, @xml_file])
  @external_resource @document_path

  defp document(), do: load_document(@document_path)

  def parse() do
    document()
    |> xpath(
      ~x"//phoneNumberMetadata/territories/territory"el,
      territories: ~x"." |> transform_by(&PhoneMetadata.from_xpath_node/1)
      )
  end
end

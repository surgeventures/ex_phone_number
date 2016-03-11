defmodule ExPhoneNumber.Metadata.PhoneNumberMetadata do
  import ExPhoneNumber.Metadata
  import SweetXml

  @resources_dir "resources"
  @xml_file "PhoneNumberMetadata.xml"
  @xml_path Path.join([@resources_dir, @xml_file])

  defp stream_document(), do: stream_document(@xml_path)

  @xml_document load_document(@xml_path)
  defp document(), do: @xml_document

  def valid_region_code?(region_code) do
    region_code_xpath = ~x"//phoneNumberMetadata/territories/territory[@id='#{String.upcase(region_code)}']"
    document()
    |> xpath(region_code_xpath)
  end
end

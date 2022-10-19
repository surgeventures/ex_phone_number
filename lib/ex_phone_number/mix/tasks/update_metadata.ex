defmodule Mix.Tasks.UpdateMetadata do
  @moduledoc "downloads latest metadata from libphonenumber github repo"
  @shortdoc "updates metadata"

  use Mix.Task
  @files_to_download ["PhoneNumberMetadata.xml", "PhoneNumberMetadataForTesting.xml"]
  @remote_path "https://raw.githubusercontent.com/google/libphonenumber/master/resources/"
  @resources_directory "resources"

  @impl Mix.Task
  def run(_args) do
    Enum.map(@files_to_download, &download/1)
    IO.puts("files updated, check any changes with git diff")
  end

  def download(filename) do
    local_path = Path.join([File.cwd!(), @resources_directory, filename])

    with {:ok, {_status, _headers, body}} = :httpc.request([@remote_path <> filename]),
         _ <- File.write(local_path, body) do
      IO.puts("written #{length(body)} bytes to #{local_path}")
    end
  end
end

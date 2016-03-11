defmodule ExPhoneNumber.Metadata do

  def stream_document(path) when is_binary(path) do
    File.stream!(path, [:read])
  end

  def load_document(path) when is_binary(path) do
    File.read!(path)
  end

end

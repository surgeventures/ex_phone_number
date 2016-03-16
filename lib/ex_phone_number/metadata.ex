defmodule ExPhoneNumber.Metadata do

  def load_document(path) when is_binary(path) do
    File.read!(path)
  end

end

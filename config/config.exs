use Mix.Config

config :logger,
  backends: [:console]

config :ex_phone_number,
  metadata_file: "PhoneNumberMetadata.xml"

import_config "#{Mix.env}.exs"

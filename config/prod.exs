use Mix.Config

secret_key_base = System.get_env("keyphrase")
azure_translator_api_key = System.get_env("ivphrase")

if !(secret_key_base && azure_translator_api_key) do
  throw("Must set secret_key_base and azure_translator_api_key environment variables in production!")
end

config :multi_translate_api, MultiTranslateApiWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :multi_translate_api, MultiTranslateApiWeb.Endpoint,
  secret_key_base: secret_key_base

config :multi_translate_api,
  azure_translator_api_key: azu

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :multi_translate_api, MultiTranslateApiWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :multi_translate_api, MultiTranslateApiWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :multi_translate_api, MultiTranslateApiWeb.Endpoint, server: true
#

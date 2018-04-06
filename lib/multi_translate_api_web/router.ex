defmodule MultiTranslateApiWeb.Router do
  use MultiTranslateApiWeb, :router
  @client_auth_key :multi_translate_api |> Application.get_env(:client_auth_key)

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MultiTranslateApiWeb do
    pipe_through [:authenticate, :api]

    # /translate endpoint is looking for query 2 params. iso_codes param is optional
    # 1. text -> the string you want to translate
    # 2. iso_codes -> a json string array of iso_code strings. ex: "[\"ex\", \"ja\", \"zh\"]"
    get "/translate", TranslationController, :translate
    get "/iso-table", TranslationController, :iso_table
  end

  defp authenticate(conn, _opts) do
    api_key = conn |> get_req_header("api-key") |> List.first()

    if api_key == @client_auth_key do
      conn
    else
      conn
      |> send_resp(401, "Unauthorized")
      |> halt
    end
  end
end

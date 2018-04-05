defmodule MultiTranslateApiWeb.Router do
  use MultiTranslateApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MultiTranslateApiWeb do
    pipe_through :api

    # /translate endpoint is looking for query 2 params. iso_codes param is optional
    # 1. text -> the string you want to translate
    # 2. iso_codes -> a json string array of iso_code strings. ex: "[\"ex\", \"ja\", \"zh\"]"
    get "/translate", TranslationController, :translate
    get "/iso-table", TranslationController, :iso_table
  end
end

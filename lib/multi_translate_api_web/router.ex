defmodule MultiTranslateApiWeb.Router do
  use MultiTranslateApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MultiTranslateApiWeb do
    pipe_through :api

    get "/translate/:text", TranslationController, :translate
    get "/iso-codes", TranslationController, :iso_codes
  end
end

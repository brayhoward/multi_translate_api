defmodule MultiTranslateApiWeb.TranslationController do
  use MultiTranslateApiWeb, :controller

  alias Translator.{Client, Worker}

  @iso_codes Client.iso_codes()

  def translate(conn, %{"text" => text, "iso_codes" => iso_codes}) do
    translations = text |> get_translations(iso_codes)

    conn
    |> render_translations(translations)
  end
  def translate(conn, %{"text" => text}) do
    translations = text |> get_translations()

    conn
    |> render_translations(translations)
  end

  defp render_translations(conn, translations) do
    conn
    |> render(
      "translations.json",
      %{translations: translations}
    )
  end

  def iso_codes(conn, _params) do
    conn |> json(@iso_codes)
  end

  def get_translations(text) do
    @iso_codes |> Worker.translate(text)
  end
  def get_translations(text, iso_codes) do
    iso_codes
    |> Jason.decode!()
    |> Worker.translate(text)
  end
end
defmodule MultiTranslateApiWeb.TranslationController do
  use MultiTranslateApiWeb, :controller

  alias Translator.{Fetcher, Worker}

  @iso_codes Fetcher.iso_codes()

  @iso_table Fetcher.iso_table()

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

  def iso_table(conn, _params) do
    conn |> json(%{data: @iso_table})
  end

  defp render_translations(conn, translations) do
    conn
    |> render(
      "translations.json",
      %{translations: translations}
    )
  end

  defp get_translations(text) do
    @iso_codes
    |> process_translations(text)
  end
  defp get_translations(text, iso_codes) do
    iso_codes
    |> Jason.decode!()
    |> process_translations(text)
  end

  defp process_translations(iso_codes, text) do
    text |> Fetcher.fetch_translations(iso_codes)
  end
end
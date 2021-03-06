defmodule MultiTranslateApiWeb.TranslationController do
  use MultiTranslateApiWeb, :controller

  alias MultiTranslateApiWeb.ErrorView
  alias Translator.{Fetcher, Worker}

  @iso_codes Fetcher.iso_codes()
  @iso_table Fetcher.iso_table()

  def translate(conn, %{"text" => text} = params) do
    codes = params["iso_codes"]

    case text |> get_translations(codes) do
      :error ->
        conn
        |> put_status(500)
        |> render(ErrorView, "500.json")

      translations ->
        conn |> render_translations(translations)
    end
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

  defp get_translations(text, "[]"), do: []
  defp get_translations(text, nil) do
    @iso_codes
    |> process_translations(text)
  end
  defp get_translations(text, iso_codes) do
    iso_codes
    |> Jason.decode!()
    |> process_translations(text)
  end

  defp process_translations(iso_codes, text) do
    # text |> Fetcher.fetch_translations(iso_codes)
    iso_codes |> Worker.translate(text)
  end
end
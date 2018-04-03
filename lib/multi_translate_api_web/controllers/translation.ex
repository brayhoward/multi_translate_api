defmodule MultiTranslateApiWeb.TranslationController do
  use MultiTranslateApiWeb, :controller

  import SweetXml

  @azure_translator_key (
    :multi_translate_api
    |> Application.get_env(:azure_translator_api_key)
  )
  @iso_table %{
    "es" => "Spanish",
    "zh" => "Chinese",
    "ja" => "Japanese",
    "ar" => "Arabic",
    "hi" => "Hindi",
    "pt" => "Portuguese",
    "ru" => "Russian",
    "bn" => "Bengali",
    "de" => "German",
    "id" => "Italian",
    "ms" => "Malay",
    "vi" => "Vietnamese",
    "ko" => "Korean",
    "fr" => "French",
    "tr" => "Turkish",
    "fa" => "Persian",
    "pl" => "Polish",
    "nl" => "Dutch"
  }
  @iso_keys Map.keys(@iso_table)

  def translate(conn, %{"text" => text}) do
    conn
    |> render(
      "translations.json",
      %{translations: translate(text)}
    )
  end

  #################
  ##   Private   ##
  #################
  def translate(text) do
    @iso_keys
    |> Task.async_stream(
      fn(isoCode) ->
        translate(text, isoCode)
      end
    )
    |> Enum.map(
      fn({_ok, translation}) ->
        translation
      end
    )
  end

  def translate(text, isoCode) do
    build_query_url(text, isoCode)
    |> HTTPoison.get!([
      {"Ocp-Apim-Subscription-Key", @azure_translator_key}
    ])
    |> Map.get(:body)
    |> parse_resp_body()
    |> build_translation(isoCode)
  end

  def build_translation(translated_text, isoCode) do
    lang = @iso_table |> Map.get(isoCode)

    %{text: translated_text, language: lang}
  end

  def parse_resp_body("<html>" <> _rest) do
    "Error: could not translate"
  end
  def parse_resp_body(response) do
    response
    |> xpath(~x"//string/text()"S)
  end

  def build_query_url(text, isoCode) do
    url = "https://api.microsofttranslator.com/V2/Http.svc/Translate"
    encodedText = URI.encode(text);
    query = "?text=#{encodedText}&to=#{isoCode}&from=en"

    url <> query
  end
end
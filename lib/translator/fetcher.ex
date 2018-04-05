defmodule Translator.Fetcher do
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
  @iso_codes Map.keys(@iso_table)

  def iso_codes, do: @iso_codes

  def iso_table, do: @iso_table

  def fetch_translations(text, iso_codes) do
    iso_codes
    |> Task.async_stream(
      fn(iso_code) ->
        fetch_translation(text, iso_code)
      end,
      ordered: false
    )
    |> Stream.map(
      fn({_ok, translation}) ->
        translation
      end
    )
    |> Enum.to_list()
  end

  def fetch_translation(text, iso_code) do
    build_query_url(text, iso_code)
    |> HTTPoison.get!([
      {"Ocp-Apim-Subscription-Key", @azure_translator_key}
    ])
    |> Map.get(:body)
    |> parse_resp_body()
    |> build_translation(iso_code)
  end

  defp build_translation(translated_text, iso_code) do
    lang = @iso_table |> Map.get(iso_code)

    %{text: translated_text, language: lang}
  end

  defp parse_resp_body("<html>" <> _rest) do
    "Error: could not translate"
  end
  defp parse_resp_body(response) do
    response
    |> xpath(~x"//string/text()"S)
  end

  defp build_query_url(text, iso_code) do
    url = "https://api.microsofttranslator.com/V2/Http.svc/Translate"
    encodedText = URI.encode(text);
    query = "?text=#{encodedText}&to=#{iso_code}&from=en"

    url <> query
  end

end
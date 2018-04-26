defmodule Translator.Fetcher do
  import SweetXml

  @azure_translator_key (
    :multi_translate_api
    |> Application.get_env(:azure_translator_api_key)
  )
  @iso_table %{
    "ar" => "Arabic",
    "bn" => "Bengali",
    "zh" => "Chinese",
    "nl" => "Dutch",
    "fr" => "French",
    "de" => "German",
    "hi" => "Hindi",
    "id" => "Italian",
    "ja" => "Japanese",
    "ko" => "Korean",
    "ms" => "Malay",
    "fa" => "Persian",
    "pl" => "Polish",
    "pt" => "Portuguese",
    "ru" => "Russian",
    "es" => "Spanish",
    "tr" => "Turkish",
    "vi" => "Vietnamese"
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
      timeout: 5_000
    )
    |> Stream.map(
      fn({_ok, translation}) ->
        translation
      end
    )
    |> Stream.reject(&(&1 === :error))
    |> order_translations_by_language()
    |> translations_length_or_error()
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

  defp build_translation(:error, _iso_codes), do: :error
  defp build_translation(translated_text, iso_code) do
    lang = @iso_table |> Map.get(iso_code)

    %{text: translated_text, language: lang}
  end

  defp parse_resp_body("<html>" <> _error_html) do
    :error
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

  defp order_translations_by_language(translations) do
    translations
    |> Enum.sort(
      # sort alphebetically
      fn(%{language: l1}, %{language: l2}) ->
        l1 < l2
      end
    )
  end

  defp translations_length_or_error(translations) do
    if length(translations) > 0 do
      translations
    else
      :error
    end
  end
end

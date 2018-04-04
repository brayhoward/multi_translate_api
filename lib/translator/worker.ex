defmodule Translator.Worker do
  use GenServer

  alias Translator.Fetcher

  ###########################################################
  ##                      PUBLIC API                       ##
  ###########################################################
  def translate(iso_codes, text) do
    initial_state = %{
      text: text,
      iso_codes_length: length(iso_codes),
      translations: []
    }
    :ok = GenServer.call(__MODULE__, {:set_state, initial_state})

    iso_codes
    |> Enum.each(&(GenServer.cast(__MODULE__, {:get_translation, &1})))

    get_translations()
  end
  ###########################################################

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_call({:set_state, new_state}, _from, _state), do: {:reply, :ok, new_state}
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_cast({:get_translation, iso_code}, state) do
    translation = Fetcher.fetch_translation(state.text, iso_code);
    updated_state = state |> Map.update!(:translations, &([translation | &1]))

    {:noreply, updated_state}
  end

  ###########################################################
  ##                      PRIVATE                          ##
  ###########################################################
  defp get_translations() do
    %{iso_codes_length: iso_codes_length, translations: translations} = get_state()
    all_translations_fetched = iso_codes_length === length(translations)

    if all_translations_fetched do
      translations
    else
      get_translations()
    end
  end

  defp get_state(), do: GenServer.call(__MODULE__, :get_state)
end

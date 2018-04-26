defmodule Translator.Worker do
  use GenServer

  alias Translator.{Server, Fetcher}

  @call_timeout (
    if Mix.env() == :dev do
      60 * 1_000
    else
      5_000
    end
  )

  ###########################################################
  ##                      PUBLIC API                       ##
  ###########################################################
  def translate(iso_codes, text) do
    state = %{
      iso_codes_length: length(iso_codes),
      translations: []
    }
    :ok = set_state(state)

    iso_codes
    |> Enum.each(&(
      Server.translate_text(text, &1)
    ))

    get_translations()
  end

  def receive_translation(translation) do
    GenServer.cast(__MODULE__, {:receive_translation, translation})
  end
  ###########################################################

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_cast({:set_state, new_state}, _state) do
    {:noreply, new_state}
  end
  def handle_cast({:receive_translation, translation}, state) do
    updated_state = state |> Map.update!(:translations, &([translation | &1]))

    {:noreply, updated_state}
  end

  ###########################################################
  ##                      PRIVATE                          ##
  ###########################################################
  defp get_translations() do
    %{iso_codes_length: iso_codes_length, translations: translations} = get_state()
    all_translations_fetched? = iso_codes_length === length(translations)

    if all_translations_fetched? do
      translations
    else
      get_translations()
    end
  end
  defp set_state(state), do: GenServer.cast(__MODULE__, {:set_state, state})
  defp get_state, do: GenServer.call(__MODULE__, :get_state, @call_timeout)
end

defmodule Translator.Server do
  use GenServer

  alias Translator.{Server, Worker, Fetcher}

  ###########################################################
  ##                      PUBLIC API                       ##
  ###########################################################
  def translate_text(text, iso_code) do
    GenServer.cast(__MODULE__, {:get_translation, {text, iso_code}})
  end
  ###########################################################

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_cast({:get_translation, {text, iso_code}}, _state) do
    Fetcher.fetch_translation(text, iso_code)
    |> Worker.receive_translation()

    {:noreply, %{}}
  end
end
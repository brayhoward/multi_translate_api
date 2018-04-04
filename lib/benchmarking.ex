alias Translator.{Fetcher, Worker}

defmodule Benchmarking do
  @iso_codes Translator.Fetcher.iso_codes()
  @inflated_iso_codes Enum.reduce(
    1..10,
    @iso_codes,
    fn(_i, acc) ->
      @iso_codes ++ acc
    end
  )
  @text "Hello, can you help me figure out which implementaion is faster?"

  def run do
    Benchee.run(
      %{
        "genserver_implementation" => fn ->
          @inflated_iso_codes
          |> Worker.translate(@text)
        end,
        "task_async_stream_implementaion" => fn ->
          @text
          |> Fetcher.fetch_translations(@inflated_iso_codes)
        end
      },
      time: 10
    )
  end
end

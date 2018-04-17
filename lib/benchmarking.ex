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
    :normal_load   |> run()
    :inflated_load |> run()
  end
  def run(:normal_load) do
    IO.puts "NORMAL LOAD"
    run_with(@iso_codes)
    IO.puts "\n\n"
  end
  def run(:inflated_load) do
    IO.puts "INFLATED LOAD"
    run_with(@inflated_iso_codes)
    IO.puts "\n\n"
  end

  defp run_with(iso_codes) do
    Benchee.run(
      %{
        "genserver_implementation" => fn ->
          iso_codes
          |> Worker.translate(@text)
        end,
        "task_async_stream_implementaion" => fn ->
          @text
          |> Fetcher.fetch_translations(@inflated_iso_codes)
        end
      },
      time: 10
    )
    :ok
  end
end

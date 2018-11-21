defmodule App.Responder.Tracking do
  import Ecto.Query
  alias App.{Repo, TrackingCode}

  def list(chat_id) do
    trackings = TrackingCode
    |> where(chat_id: ^chat_id)
    |> Repo.all
    |> Repo.preload([:events])
    |> Enum.map(&__MODULE__.tracking_markdown/1)
  end

  def tracking_markdown(tracking, events \\ []) do
    IO.inspect events
    events = if events |> Enum.empty? do
      tracking.events
    end
    IO.inspect events

    info = "📦 *Tracking:* #{tracking.code}\n"
    info_events = Enum.map(events, fn(event) ->
      ["*" <> event.message <> "*", event.event_date] |> Enum.join(" # ")
    end) |> Enum.join("\n")

    IO.puts info
    IO.puts info_events

    info <> info_events <> "\n\n"
  end


end

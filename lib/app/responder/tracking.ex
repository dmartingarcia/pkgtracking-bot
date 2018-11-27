defmodule App.Responder.Tracking do
  import Ecto.Query
  alias App.{Repo, TrackingCode, Event}

  def list(chat_id) do
    trackings = TrackingCode
    |> where(chat_id: ^chat_id)
    |> Repo.all
    |> Repo.preload([:events])
    |> Enum.map(&__MODULE__.tracking_markdown/1)
  end

  def tracking_markdown(tracking, events \\ []) do
    events = if Enum.empty?(events) do
      tracking.events
    else
      events
    end

    info = "📦 *Tracking:* `#{tracking.code}`\n"

    info = if tracking.ended do
      "✅"<> info
    else
      info
    end

    info_events = Enum.map(events, fn(event) ->
      ["*" <> event.message <> "*", event.event_date, "(" <> event.source <> ")"] |> Enum.join(" # ")
    end) |> Enum.join("\n")

    info <> info_events <> "\n\n"
  end
end

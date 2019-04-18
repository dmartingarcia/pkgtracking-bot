defmodule App.Responder.Tracking do
  import Ecto.Query
  alias App.{Repo, TrackingCode, Event}

  def delete_ended(chat_id) do
    ended_tracking_codes = TrackingCode
    |> where([t], t.chat_id == ^chat_id and t.ended and not(t.deleted))

    Repo.update_all(from(t in TrackingCode, join: s in subquery(ended_tracking_codes), on: s.id == t.id), set: [deleted: true])
  end

  def list(chat_id) do
    tracking_codes = TrackingCode
    |> where([t], t.chat_id == ^chat_id and not(t.deleted))
    |> order_by([t], t.ended)
    |> Repo.all
    |> Repo.preload([:events])


    tracking_codes |> Enum.chunk_every(5) |> Enum.map(fn(tracking_group) ->
      message = tracking_group |> Enum.map(&__MODULE__.tracking_markdown/1)
      {:ok, _} = Nadia.send_message(chat_id, message, [parse_mode: :markdown])
    end)
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

    info_events = Enum.sort_by(events, fn(event) -> event.event_date end) |> Enum.map(fn(event) ->
      ["*" <> event.message <> "*", event.detailed_message, event.event_date, "(" <> event.source <> ")"] |> Enum.join(" # ")
    end) |> Enum.join("\n")

    info <> info_events <> "\n\n"
  end
end

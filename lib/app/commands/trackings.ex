defmodule App.Commands.Trackings do
  use App.Commander
  import Ecto.Query
  alias App.PostalService.{Correos, CorreosExpress}
  alias App.{Repo, Event, TrackingCode}

  #/update
  def update(update) do
    chat_id = get_chat_id()
    trackings = TrackingCode
    |> where(chat_id: ^chat_id)
    |> where([t], is_nil(t.ended))
    |> or_where([t], t.ended == false)
    |> Repo.all
    |> Repo.preload([:events])
    |> Enum.map(fn(tracking) -> update_tracking_code(update, tracking) end)
  end

  #/tracking_list
  def list(update) do
    message = App.Responder.Tracking.list(get_chat_id())
    {:ok, _} = send_message(message, parse_mode: :markdown)
  end

  #/add_tracking $code
  def add(update) do
    code = String.split(update.message.text, " ") |> List.last

    tracking = find_or_create_tracking(code, get_chat_id())

    App.TrackingCodeUpdater.update_tracking_code(tracking)
  end

  defp find_or_create_tracking(code, chat_id) do
    case Repo.get_by(TrackingCode, code: code, chat_id: chat_id) do
      nil ->
        tracking = %TrackingCode{code: code, chat_id: chat_id}
        Repo.insert!(tracking)
      result ->
        result
    end
  end
end

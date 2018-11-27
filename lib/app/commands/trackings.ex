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

    update_tracking_code(update, tracking)
  end

  defp update_tracking_code(update, tracking) do
    Repo.transaction(fn ->

      services = service_list |> Enum.filter(fn(service) ->  service.valid_tracking?(tracking.code) end)
      events = Enum.map(services, fn(service) -> service.obtain_events(tracking.code) end) |> List.flatten
      new_events = select_and_create_new_events(events, tracking)
      is_finished = !(Enum.filter(events, fn(event) -> event.ending_event end) |> Enum.empty?)
      if is_finished do
        set_as_finished(tracking)
      end

      if new_events |> Enum.any? do
        message = App.Responder.Tracking.tracking_markdown(tracking, new_events)
        send_message(message, parse_mode: :markdown)
      end
    end)
  end

  defp service_list do
    [Correos, CorreosExpress]
  end

  defp set_as_finished(tracking) do
    changeset = TrackingCode.changeset(tracking, %{ended: true})
    Repo.update!(changeset)
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

  defp select_and_create_new_events(events, tracking) do
    new_events = []

    Enum.filter(events,
      fn(event) ->
        case Repo.get_by(Event, message: event.message, tracking_code_id: tracking.id) do
          nil ->
            event = Map.merge(event, %{tracking_code_id: tracking.id})
            Repo.insert!(event)

            true
          result ->
            false
        end
      end
    )
  end
end

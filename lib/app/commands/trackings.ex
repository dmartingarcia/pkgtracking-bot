defmodule App.Commands.Trackings do
  # Notice that here we just `use` Commander. Router is only
  # used to map commands to actions. It's best to keep routing
  # only in App.Commands file. Commander gives us helpful
  # macros to deal with Nadia functions.
  use App.Commander
  alias App.{Repo, Event, TrackingCode}
  # Functions must have as first parameter a variable named
  # update. Otherwise, macros (like `send_message`) will not
  # work as expected.

  #/tracking_list
  def list(update) do
    send_message(App.Responder.Tracking.list(get_chat_id()), parse_mode: :markdown)
  end

  #/add_tracking $code
  def add(update) do
    code = String.split(update.message.text, " ") |> List.last
    tracking = find_or_create_tracking(code, get_chat_id())

    Repo.transaction(fn ->
      events = App.PostalService.Correos.obtain_events(code)
      new_events = select_and_create_new_events(events, tracking)
      is_finished = !(Enum.filter(events, fn(event) -> event.ending_event end) |> Enum.empty?)
      if is_finished do
        set_as_finished(tracking)
      end
      message = App.Responder.Tracking.tracking_markdown(tracking, new_events)
      send_message(message, parse_mode: :markdown)
    end)
  end

  defp set_as_finished(tracking) do
    changeset = TrackingCode.changeset(tracking, %{ended: true})
    IO.inspect changeset

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
        IO.inspect tracking
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

defmodule App.Commands.Trackings do
  # Notice that here we just `use` Commander. Router is only
  # used to map commands to actions. It's best to keep routing
  # only in App.Commands file. Commander gives us helpful
  # macros to deal with Nadia functions.
  use App.Commander
  alias App.{Repo, TrackingCode}
  # Functions must have as first parameter a variable named
  # update. Otherwise, macros (like `send_message`) will not
  # work as expected.

  #/tracking_list
  def list(update) do
    send_message(App.Responder.Tracking.list(get_chat_id))
  end

  #/add_tracking $code
  def add(update) do
    code = String.split(update.message.text, " ") |> List.last

    tracking =
      case Repo.get_by(TrackingCode, code: code, chat_id: get_chat_id()) do
        nil ->
          tracking = %TrackingCode{code: code, chat_id: get_chat_id()}
          Repo.insert!(tracking)

          tracking
        result -> result
      end

    Logger.log(:info, code)
    IO.inspect(tracking)
    events = App.PostalService.Correos.obtain_events(code)
    message = App.Responder.Tracking.tracking_markdown(tracking, events)
    send_message(message)
  end
end

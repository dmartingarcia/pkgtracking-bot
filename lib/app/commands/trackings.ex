defmodule App.Commands.Trackings do
  use App.Commander
  import Ecto.Query
  alias App.PostalService.{Correos, CorreosExpress}
  alias App.{Repo, Event, TrackingCode}

  #/tracking_list
  def list(update) do
    message = App.Responder.Tracking.list(get_chat_id())
    {:ok, _} = send_message(message, parse_mode: :markdown)
  end

  #/add_tracking $code
  def add(update) do
    code = String.split(update.message.text, " ") |> List.last

    case(find_or_create_tracking(code, get_chat_id())) do
      {:created, tracking} ->
        App.TrackingCodeUpdater.update_tracking_code(tracking)
      {:exists, tracking} ->
        App.Responder.Tracking.element(get_chat_id(), tracking)
    end
  end

  #/delete_ended
  def delete_ended(update) do
    App.Responder.Tracking.delete_ended(get_chat_id())
    {:ok, _} = send_message("*Ended trackings deleted!* :rocket:", parse_mode: :markdown)
  end

  defp find_or_create_tracking(code, chat_id) do
    case Repo.get_by(TrackingCode, code: code, chat_id: chat_id) do
      nil ->
        tracking = %TrackingCode{code: code, chat_id: chat_id}
        {:created, Repo.insert!(tracking)}
      result ->
        {:exists, result}
    end
  end
end

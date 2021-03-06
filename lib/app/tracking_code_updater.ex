defmodule App.TrackingCodeUpdater do
  use GenServer
  require Logger
  import Ecto.Query
  alias App.PostalService.{Correos, CorreosExpress, Sky56, Gls, Chinapost, SingaporePost, Cainiao, DhlEs, DhlDe}
  alias App.{Repo, Event, TrackingCode}

  def start_link do
    Logger.log(:info, "Started TrackingCodeUpdater")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    update_trackings()
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # do important stuff
    update_trackings()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1000 * 60 * 30)
  end

  defp update_trackings do
    Logger.log(:info, "Updating tracking codes")

    TrackingCode
    |> where([t], not(t.ended))
    |> Repo.all
    |> Repo.preload([:events])
    |> Enum.map(fn(tracking) -> update_tracking_code(tracking) end)
  end

  def update_tracking_code(tracking) do
    try do
      services = service_list() |> Enum.filter(fn(service) ->  service.valid_tracking?(tracking.code) end)
      events = Enum.map(services, fn(service) -> service.obtain_events(tracking.code) end) |> List.flatten
      Repo.transaction(fn ->
        new_events = select_and_create_new_events(events, tracking)
        is_finished = !(Enum.filter(events, fn(event) -> event.ending_event end) |> Enum.empty?)
        if is_finished do
          set_as_finished(tracking)
        end

        if new_events |> Enum.any? do
          message = App.Responder.Tracking.tracking_markdown(tracking, new_events)
          Nadia.send_message(tracking.chat_id, message, [parse_mode: :markdown])
        end
      end)
    rescue
      exception ->
        master_telegram_chat_id = 102026333

        IO.inspect(exception)
        IO.inspect(Exception.format_stacktrace(__STACKTRACE__))

        Nadia.send_message(master_telegram_chat_id, inspect(exception))
        Nadia.send_message(master_telegram_chat_id, Exception.format_stacktrace(__STACKTRACE__))

        Sentry.capture_exception(exception, [stacktrace: __STACKTRACE__])
    end
  end

  defp service_list do
    [Correos, CorreosExpress, Sky56, Gls, Chinapost, SingaporePost, Cainiao, DhlDe, DhlEs]
  end

  defp set_as_finished(tracking) do
    changeset = TrackingCode.changeset(tracking, %{ended: true})
    Repo.update!(changeset)
  end

  defp select_and_create_new_events(events, tracking) do
    Enum.filter(events,
      fn(event) ->
        case Repo.get_by(Event, internal_code: event.internal_code, tracking_code_id: tracking.id) do
          nil ->
            event = Map.merge(event, %{tracking_code_id: tracking.id})
            Repo.insert!(event)

            true
          _ ->
            false
        end
      end
    )
  end
end

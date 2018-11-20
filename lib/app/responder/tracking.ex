defmodule App.Responder.Tracking do
  import Ecto.Query
  alias App.{Repo, TrackingCode}

  def list(chat_id) do
    TrackingCode
    |> where(chat_id: ^chat_id)
    |> Repo.all
    |> Enum.map(&__MODULE__.tracking_markdown/1)
  end

  def tracking_markdown(tracking, events \\ []) do
  """
  :package: Tracking Code: #{tracking.code}
  #{inspect events}
  """
  end


end

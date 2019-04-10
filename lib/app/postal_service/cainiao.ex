defmodule App.PostalService.Cainiao do
  import Meeseeks.CSS

  def obtain_events(tracking_code) do
    url = String.replace(url(),"&TRACKING_CODE", tracking_code)

    {:ok, %{body: body}} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])

    case body |> Poison.decode! |> Map.fetch!("data") |> List.first |> Map.fetch!("section2") |> Map.fetch("detailList") do
      {:ok, results} ->
        results |> Enum.map(&parse_event/1)
      {:error, _} ->
        []
    end
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/^[0-9A-Z]+$/, tracking_code)
  end

  defp parse_event(event_body) do
    IO.inspect event_body
    message = event_body["desc"]

    is_ending = String.contains?(String.downcase(message), "delivered")

    %App.Event{
      event_date: parse_date(event_body["time"]),
      detailed_message: nil,
      message: String.capitalize(message),
      internal_code: event_body["status"] || "",
      location: nil,
      ending_event: is_ending,
      source: "Cainiao"
    }
  end

  defp parse_date(date_string) do
    date_string |> String.split(" ") |> List.first |> Date.from_iso8601!
  end

  defp url do
    "https://global.cainiao.com/trackWebQueryRpc/getTrackingInfos.json?mailNoList=&TRACKING_CODE"
  end
end

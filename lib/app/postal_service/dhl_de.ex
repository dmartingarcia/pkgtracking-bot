defmodule App.PostalService.DhlDe do
  def obtain_events(tracking_code) do
    url = String.replace(url(),"&TRACKING_CODE", tracking_code)
    IO.puts "DHL for #{tracking_code} -> #{url}"

    {:ok, %{body: body}} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])

    case parse_body(body) do
      {:ok, results} ->
        results |> get_events_from_json |> Enum.map(&parse_event/1)
      {:error, _} ->
        []
    end
  end

  defp get_events_from_json(json) do
    json
    |> Map.fetch!("sendungen")
    |> Enum.at(0)
    |> Map.fetch!("sendungsdetails")
    |> Map.fetch!("sendungsverlauf")
    |> Map.fetch!("events")
  end

  defp parse_body(body) do
    body |> String.split("JSON.parse(\"") |> Enum.at(1) |> String.split("\"),") |> Enum.at(0) |> String.replace("\\", "") |> Poison.decode
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/^ct[0-9]{9}[a-z]{2}$/, String.downcase(tracking_code))
  end

  defp parse_event(event) do
    message = Map.fetch!(event, "status")
    is_ending = String.downcase(message) |> String.contains?("delivered")

    %App.Event{
      event_date: parse_date(event),
      detailed_message: nil,
      message: message,
      internal_code: message,
      location: parse_location(event),
      ending_event: is_ending,
      source: "DHL"
    }
  end

  defp parse_location(event) do
    case Map.fetch(event, "ort") do
      {:ok, location} -> location
      _ -> nil
    end
  end

  defp parse_date(event) do
    {_, date_string} = Map.fetch(event, "datum")
    {_, date, _} = DateTime.from_iso8601(date_string)
    date |> DateTime.to_date
  end

  defp url do
    "https://www.dhl.de/int-verfolgen/?lang=en&domain=de&lang=en&domain=de&lang=en&domain=de&lang=en&domain=de&piececode=&TRACKING_CODE"
  end
end

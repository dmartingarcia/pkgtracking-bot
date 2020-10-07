defmodule App.PostalService.DhlEs do
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
    # TODO delivery date?
    json
    |> Map.fetch!("Seguimiento")
  end

  defp parse_body(body) do
    body |> Poison.decode
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/^ct[0-9]{9}[a-z]{2}$/, String.downcase(tracking_code))
  end

  defp parse_event(event) do
    message = Map.fetch!(event, "Descripcion") |> String.trim
    is_ending = String.downcase(message) |> String.contains?("entregado")

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
    case Map.fetch(event, "Ciudad") do
      {:ok, location} -> location
      _ -> nil
    end
  end

  defp parse_date(event) do
    hour = Map.fetch!("Hora")
    |> String.split("/")
    |> Enum.reverse
    |> Enum.join("-")

    day = Map.fetch!("Fecha")

    date_string = day <> "T" <> hour
    date_string |> DateTime.from_iso8601!
  end

  defp url do
    "https://clientesparcel.dhl.es/LiveTracking/api/expediciones?numeroExpedicion=&TRACKING_CODE"
  end
end

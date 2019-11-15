defmodule App.PostalService.Gls do

  def obtain_events(tracking_code) do
    url = String.replace(url(),"$TRACKING_CODE", tracking_code)
    {:ok, %{body: body}} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])
    IO.puts url
    result = Poison.Parser.parse!(body, %{})
    result = case result["tuStatus"] do
               nil ->
                 []
               status ->
                 result = Enum.at(status, 0)
                 result["history"] |> Enum.map(&parse_event/1)
             end
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/^[0-9]{14}$/, tracking_code) #47150050471839
  end

  defp parse_event(event) do
    message = event["evtDscr"]
    is_ending = String.contains?(String.downcase(message), "envío entregado")

    location_string = Enum.join([event["address"]["city"], event["address"]["countryName"]], ", ")

    %App.Event{
      event_date: parse_date(event["date"]),
      message: message |> String.capitalize,
      internal_code: String.slice(message, 0..6),
      location: location_string,
      ending_event: is_ending,
      source: "Gls"
    }
  end

  defp parse_date(date_string) do
    Timex.parse!(date_string, "%Y-%m-%d", :strftime) |> Timex.to_date
  end

  defp url do
    "https://www.gls-spain.es/tracking_code.php?match=$TRACKING_CODE"
  end
end

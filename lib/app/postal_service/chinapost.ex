defmodule App.PostalService.Chinapost do
  import Meeseeks.CSS

  def obtain_events(tracking_code) do
    url = String.replace(url, "$TRACKING_CODE", tracking_code)
    
    {:ok, %{body: body}} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])
    IO.inspect url
    case body |> Meeseeks.parse |> Meeseeks.fetch_all(css("table:nth-child(11) tr:not(:first-child)")) do
      {:ok, results} ->
        results |> Enum.map(&parse_event/1)
      {:error, _} ->
        []
    end
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/R[A-Z]{1}[0-9]{9}CN/, tracking_code) # RY388817948CN // RP096465723CN
  end

  defp parse_event(event_body) do
    {:ok, fields} = Meeseeks.fetch_all(event_body, css("td"))
    datetime = fields |> Enum.at(0) |> Meeseeks.text 
    message = fields |> Enum.at(1) |> Meeseeks.text
    location = fields |> Enum.at(2) |> Meeseeks.text
    
    %App.Event{
      event_date: parse_date(datetime),
      message: message |> String.capitalize,
      internal_code: String.slice(message, 0..6),
      location: location,
      ending_event: false,
      source: "ChinaPost"
    }
  end

  defp parse_date(date_string) do
    date_string
    |> String.split(" ")
    |> Enum.at(0)
    |> String.split("/")
    |> Enum.map(fn(date) ->  String.pad_leading(date, 2, "0") end)
    |> Enum.join("-")
    |> Date.from_iso8601!
  end

  defp url do
    "http://track-chinapost.com/result_global.php?code=$TRACKING_CODE"
  end
end

defmodule App.PostalService.CorreosExpress do
  import Meeseeks.CSS

  def obtain_events(tracking_code) do
    url = String.replace(url(),"&TRACKING_CODE", tracking_code)
    {:ok, %{body: body}} = HTTPoison.get(url)

    case body |> Meeseeks.parse |> Meeseeks.fetch_all(css(".tracking table tbody tr")) do
      {:ok, results} ->
        results |> Enum.map(&parse_event/1)
      {:error, _} ->
        []
    end
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/[0-9]{9}/, tracking_code)
  end

  defp parse_event(event_body) do
    [message | detailed_message] = Meeseeks.one(event_body, css("td:nth-child(3)")) |> Meeseeks.text |> String.split(".", parts: 2)

    is_ending = String.contains?(String.downcase(message), "entregado")

    %App.Event{
      event_date: parse_date(Meeseeks.one(event_body, css("td:nth-child(1)")) |> Meeseeks.text),
      detailed_message: detailed_message |> String.capitalize,
      message: message |> String.capitalize,
      internal_code: message,
      location: Meeseeks.one(event_body, css("td:nth-child(2)")) |> Meeseeks.text,
      ending_event: is_ending,
      source: "CorreosExpress"
    }
  end

  defp parse_date(date_string) do
    date_string = date_string |> String.split(", ") |> Enum.at(-1)
    date_string = date_string <> ":00"

    result = String.split(date_string, " ")
    date = Enum.at(result, 0) |> String.split("/") |> Enum.reverse |> Enum.join("-")

    date |> Date.from_iso8601!
  end

  defp url do
    "https://www.cexpr.es/c?n=&TRACKING_CODE"
  end
end

defmodule App.PostalService.Sky56 do

  def obtain_events(tracking_code) do
    url = String.replace(url(),"$TRACKING_CODE", tracking_code)
    {:ok, %{body: body}} = HTTPoison.get(url, [], [timeout: 50_000, recv_timeout: 50_000])
    
    result = Poison.Parser.parse!(body, %{})
    result = String.split(result["message"], "<br\/>") |> Enum.filter(& &1 != "")

    result |> Enum.map(&parse_event/1)
  end

  def valid_tracking?(tracking_code) do
    Regex.match?(~r/Q[0-9]{10}[a-zA-Z]{2}/, tracking_code) #Q3646159642XX
  end

  defp parse_event(message) do
    date = String.split(message, "--") |> Enum.at(1)
    message = String.split(message, "--") |> Enum.at(0)    
    is_ending = String.contains?(String.downcase(message), "entregado")

    %App.Event{
      event_date: parse_date(date),
      message: message |> String.capitalize,
      internal_code: String.slice(message, 0..6),
      ending_event: is_ending,
      source: "Sky56"
    }
  end

  defp parse_date(date_string) do
    message = String.trim(date_string) |> String.split(" ") |> Enum.at(0)
    Timex.parse!(message, "%d-%b-%Y", :strftime) |> Timex.to_date
  end

  defp url do
    "http://sky56.cn/track/track/result?tracking_number=$TRACKING_CODE"
  end
end

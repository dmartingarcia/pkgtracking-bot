defmodule App.PostalService.Correos do
  import Meeseeks.CSS

  def obtain_events(tracking_code) do
    {:ok, %{body: body}} = HTTPoison.post(url(), body(tracking_code), header())

    body = String.replace(body, ~r/<[a-zA-Z]+ \/>/, "")

    case body |> Meeseeks.parse |> Meeseeks.fetch_all(css("listaeventos evento")) do
      {:ok, results} ->
        results |> Enum.map(&parse_event/1)
      {:error, _} ->
        []
    end
  end

  defp parse_event(event_body) do
    message = Meeseeks.one(event_body, css("descripcionweb")) |> Meeseeks.text
    is_ending = String.contains?(String.downcase(message), "entregado")

    %App.Event{
      event_date: parse_date(Meeseeks.one(event_body, css("fecha")) |> Meeseeks.text),
      message: message,
      internal_code: Meeseeks.one(event_body, css("codigoevento")) |> Meeseeks.text,
      location: Meeseeks.one(event_body, css("provincia")) |> Meeseeks.text,
      ending_event: is_ending
    }
  end

  defp parse_date(date_string) do
    date_string
    |> String.split("/") |> Enum.reverse |> Enum.join("-") |> Date.from_iso8601!
  end

  defp url do
    "http://aplicacionesweb.correos.es/dinamic/servicios-web/WSLocalizador/WSLocalizadorenvios.asmx"
  end

  defp header do
    [{"Content-Type", "application/soap+xml; charset=utf-8"}]
  end

  defp body(tracking_code) do
    """
    <?xml version="1.0" encoding="utf-8"?>
    <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
    <soap12:Body>
    <SeguimientoLocalizadorEnvios xmlns="WSlocalizadorEnvios">
    <CodigoEnvio>#{tracking_code}</CodigoEnvio>
    <IdiomaWeb>es</IdiomaWeb>
    </SeguimientoLocalizadorEnvios>
    </soap12:Body>
    </soap12:Envelope>
    """
  end
end

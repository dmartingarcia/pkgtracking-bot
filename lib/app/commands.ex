defmodule App.Commands do
  use App.Router
  use App.Commander

  alias App.Commands.{Trackings}

  # See also: https://hexdocs.pm/nadia/Nadia.html

  command "tracking_list", Trackings, :list
  command "update", Trackings, :update
  command "add_tracking", Trackings, :add

  command "start" do
    Logger.log :info, "Command /start"

    {:ok, _} = send_message "Selecciona tu idioma / Select your language",
      # Nadia.Model is aliased from App.Commander
      #
      # See also: https://hexdocs.pm/nadia/Nadia.Model.InlineKeyboardMarkup.htm
      reply_markup: %Model.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %{
              callback_data: "/language es",
              text: "🇪🇸",
            },
            %{
              callback_data: "/language en",
              text: "🇬🇧",
            },
          ]
        ]
      }
  end

  # You can create command interfaces for callback querys using this macro.
  callback_query_command "language" do
    Logger.log :info, "Callback Query Command /language"

    case update.callback_query.data do
      "/language es" ->
        answer_callback_query text: "Perfecto!!"
      "/language en" ->
        answer_callback_query text: "Perfect!!"
    end
  end

  # Fallbacks

  # Rescues any unmatched callback query.
  callback_query do
    Logger.log :warn, "Did not match any callback query"

    answer_callback_query text: "Sorry, but there is no JoJo better than Joseph."
  end

  # Rescues any unmatched inline query.
  inline_query do
    Logger.log :warn, "Did not match any inline query"

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "Darude-Sandstorm Non non Biyori Renge Miyauchi Cover 1 Hour",
        thumb_url: "https://img.youtube.com/vi/yZi89iQ11eM/3.jpg",
        description: "Did you mean Darude Sandstorm?",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=yZi89iQ11eM",
        }
      }
    ]
  end

  # The `message` macro must come at the end since it matches anything.
  # You may use it as a fallback.
  message do
    Logger.log :warn, "Did not match the message"

    send_message "Sorry, I couldn't understand you"
  end
end

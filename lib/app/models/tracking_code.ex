defmodule App.TrackingCode do
  use Ecto.Schema

  schema "tracking_codes" do
    field :code
    field :chat_id, :integer

    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end
end

defmodule App.TrackingCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tracking_codes" do
    field :code
    field :chat_id, :integer
    field :ended, :boolean

    has_many :events, App.Event

    timestamps()
  end

  def changeset(tracking_code, params \\ %{}) do
    tracking_code
    |> cast(params, [:code, :chat_id, :ended])
  end
end

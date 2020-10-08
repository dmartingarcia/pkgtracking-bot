defmodule App.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :event_date, :date
    field :message, :string
    field :detailed_message, :string
    field :internal_code, :string
    field :location, :string
    field :ending_event, :boolean
    field :source, :string

    belongs_to :tracking_code, App.TrackingCode

    timestamps()
  end

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, [:event_date, :message, :detailed_message, :internal_code, :location, :ending_event, :source])
    |> validate_required([:message, :internal_code])
  end
end

defmodule App.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :event_date, :date, null: false
      add :message, :string, null: false
      add :internal_code, :string, null: false
      add :location, :string
      add :ending_event, :boolean, default: false, null: false

      add :tracking_code_id, references(:tracking_codes), null: false

      timestamps()
    end

    create index(:events, [:ending_event])
    create unique_index(:events, [:tracking_code_id, :internal_code])
  end
end

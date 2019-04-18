defmodule App.Repo.Migrations.CreateTrackingCodes do
  use Ecto.Migration

  def change do
    create table(:tracking_codes) do
      add :code, :string, null: false
      add :chat_id, :integer, null: false
      add :ended, :boolean, null: false, default: false

      timestamps()
    end

    create index(:tracking_codes, [:chat_id, :ended])
    create index(:tracking_codes, [:code, :chat_id], unique: true)
  end
end

defmodule App.Repo.Migrations.SoftDeletionOfTrackings do
  use Ecto.Migration

  def change do
    alter table(:tracking_codes) do
      add :deleted, :boolean, default: false, null: false
    end
  end
end

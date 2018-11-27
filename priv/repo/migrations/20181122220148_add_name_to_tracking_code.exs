defmodule App.Repo.Migrations.AddNameToTrackingCode do
  use Ecto.Migration

  def change do
    alter table(:tracking_codes) do
      add :name, :string
    end
  end
end

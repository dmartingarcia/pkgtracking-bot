defmodule App.Repo.Migrations.AddLastCheckToPackageTracking do
  use Ecto.Migration

  def change do
    alter table(:tracking_codes) do
      add :last_check, :utc_datetime, default: "1970-1-1" , null: false
    end
  end
end

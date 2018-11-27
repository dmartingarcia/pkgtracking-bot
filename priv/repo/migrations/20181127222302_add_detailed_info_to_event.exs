defmodule App.Repo.Migrations.AddDetailedInfoToEvent do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :detailed_message, :string, default: nil
    end
  end
end

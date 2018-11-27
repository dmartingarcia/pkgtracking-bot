defmodule App.Repo.Migrations.AddSourceToEvent do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :source, :string, default: ""
    end
  end
end

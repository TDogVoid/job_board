defmodule JobBoard.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create table(:cities) do
      add :name, :string
      add :zipcode, :integer
      add :state_id, references(:states)
      add :geom, :geometry

      timestamps()
    end
    create index(:cities, [:name])
    create index(:cities, [:zipcode])
    create index(:cities, [:state_id])

    alter table(:jobs) do
      add :city_id, references(:cities)
    end

    create index(:jobs, [:city_id])
  end
end

defmodule JobBoard.Repo.Migrations.CreateConfigs do
  use Ecto.Migration

  def change do
    create table(:configs) do
      add :ucon, :integer, default: 0
      add :site_name, :string, default: "Job Board"
      add :post_price, :integer, default: 0
      add :site_slug, :string, default: "Find Jobs"

      timestamps()
    end

    create unique_index(:configs, [:ucon])

  end
end

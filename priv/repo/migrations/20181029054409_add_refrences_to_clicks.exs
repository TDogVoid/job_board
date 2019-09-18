defmodule JobBoard.Repo.Migrations.AddRefrencesToClicks do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :click_id, references(:clicks)
      remove :click_count
    end

    alter table(:users) do
      add :click_id, references(:clicks)
      remove :click_count
    end

    create index(:users, [:click_id])
    create index(:jobs, [:click_id])
  end
end

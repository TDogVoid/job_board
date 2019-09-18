defmodule JobBoard.Repo.Migrations.RemoveClick do
  use Ecto.Migration

  def change do
    drop index(:users, [:click_id])
    drop index(:jobs, [:click_id])
    alter table(:jobs) do
      remove :click_id
    end

    alter table(:users) do
      remove :click_id
    end
    drop table(:clicks)
  end
end

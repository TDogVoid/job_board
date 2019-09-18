defmodule JobBoard.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks) do
      add :job_id, references(:jobs, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:clicks, [:job_id])
    create index(:clicks, [:user_id])
  end
end

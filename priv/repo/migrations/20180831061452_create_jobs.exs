defmodule JobBoard.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string, null: false
      add :link, :string, null: false
      add :company, :string


      timestamps()
    end

    create index(:jobs, [:link])
  end
end

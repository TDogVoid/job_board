defmodule JobBoard.Repo.Migrations.LinkJobsUser do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end

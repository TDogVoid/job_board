defmodule JobBoard.Repo.Migrations.AddClickCountToUserAndJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :click_count, :integer, default: 0
    end
    alter table(:users) do
      add :click_count, :integer, default: 0
    end
  end
end

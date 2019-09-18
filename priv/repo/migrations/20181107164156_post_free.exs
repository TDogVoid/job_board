defmodule JobBoard.Repo.Migrations.PostFree do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :post_free, :boolean, default: false, null: false
    end
  end
end

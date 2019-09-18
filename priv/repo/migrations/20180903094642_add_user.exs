defmodule JobBoard.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :company, :string, null: false

      timestamps()
    end
  end
end

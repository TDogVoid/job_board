defmodule JobBoard.Repo.Migrations.AddStripeIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :stripe_id, :string
    end

    create index(:users, [:stripe_id])
  end
end

defmodule JobBoard.Repo.Migrations.AddPaymentId do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :payment_id, :string
    end
    create index(:jobs, [:payment_id])
  end
end

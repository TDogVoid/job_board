defmodule JobBoard.Repo.Migrations.AddReceiptNumberToJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :receipt_number, :string
    end
    create index(:jobs, [:receipt_number])
  end
end

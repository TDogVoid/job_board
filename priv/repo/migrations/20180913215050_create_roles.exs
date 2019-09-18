defmodule JobBoard.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false

      add :can_edit_others_job, :boolean, default: false, null: false
      add :can_delete_others_job, :boolean, default: false, null: false

      add :can_view_user_list, :boolean, default: false, null: false
      add :can_view_other_users, :boolean, default: false, null: false
      add :can_edit_other_users, :boolean, default: false, null: false
      add :can_delete_other_users, :boolean, default: false, null: false
      add :can_promote_users, :boolean, default: false, null: false

      add :admin, :boolean, default: false, null: false

      timestamps()
    end

  end
end

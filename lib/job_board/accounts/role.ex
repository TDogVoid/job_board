defmodule JobBoard.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset


  schema "roles" do
    field :name, :string

    # jobs
    field :can_edit_others_job, :boolean, default: false
    field :can_delete_others_job, :boolean, default: false

    # user
    field :can_view_user_list, :boolean, default: false
    field :can_view_other_users, :boolean, default: false
    field :can_edit_other_users, :boolean, default: false
    field :can_delete_other_users, :boolean, default: false
    field :can_promote_users, :boolean, default: false
    field :post_free, :boolean, default: false

    field :admin, :boolean, default: false

    has_many :user, JobBoard.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :can_edit_others_job, :can_delete_others_job,
    :can_view_user_list, :can_view_other_users, :can_edit_other_users, :can_delete_other_users,
    :can_promote_users, :admin, :post_free])
    |> validate_required([:name, :can_edit_others_job, :can_delete_others_job,
    :can_view_user_list, :can_view_other_users, :can_edit_other_users, :can_delete_other_users,
    :can_promote_users, :admin, :post_free])
    |> unique_constraint(:name)
  end
end

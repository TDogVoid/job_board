defmodule JobBoard.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias JobBoard.Accounts.Credential


  schema "users" do
    field :name, :string
    field :company, :string
    field :verified, :boolean, default: false
    field :stripe_id, :string
    field :agree_terms, :boolean, default: false, virtual: true
    field :newsletter, :boolean, default: true, virtual: true
    has_one :credential, Credential, on_replace: :update
    belongs_to :role, JobBoard.Accounts.Role

    has_many :jobs, JobBoard.Jobs.Job, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :company, :role_id, :verified, :stripe_id, :agree_terms, :newsletter])
    |> validate_required([:name, :company])
  end

  def registration_changeset(user, params) do
    params = user_params(params)
    case params.agree_terms do
      "true" ->
        user
        |> changeset(params)
        |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
      _ ->
        user
        |> changeset(params)
        |> add_error(:agree_terms, "You must agree to terms")
        |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
    end
  end

  def register_direct_params(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

  def update_user(user, params) do
    params = only_allowed_changes(params)
    update_user_direct(user, params)
  end

  def update_user_direct(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.update_changeset/2, required: false)
  end

  defp user_params(params) do
    # specified user params so they can't insert role
    role_id = JobBoard.Accounts.get_default_role().id
    params =
      if params != %{} do
        %{name: params["name"],
        company: params["company"],
        role_id: role_id,
        agree_terms: params["agree_terms"],
        newsletter: params["newsletter"],
        credential: %{
          email: params["credential"]["email"],
          password: params["credential"]["password"],
          password_confirmation: params["credential"]["password_confirmation"],
          token: params["credential"]["token"]
        }}
      end
    params
  end

  def only_allowed_changes(params) do
    params =
      if params != %{} do
        %{name: params["name"],
        company: params["company"],
        credential: %{
          email: params["credential"]["email"],
          password: params["credential"]["password"],
          password_confirmation: params["credential"]["password_confirmation"],
          token: params["credential"]["token"]
        }}
      end
    params
  end

end

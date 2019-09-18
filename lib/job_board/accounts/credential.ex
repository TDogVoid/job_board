defmodule JobBoard.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset


  schema "credentials" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :token, :string
    belongs_to :user, JobBoard.Accounts.User

    timestamps()
  end

  # when making changes to the changeset remember that user changeset is specified changes so make the changes there too
  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :token, :password_confirmation])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password!")
    |> put_pass_hash()
  end

  def update_changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :token, :password_confirmation])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password!")
    |> put_pass_hash()
  end

  def tokenchangeset(credential, attrs) do
    credential
    |> cast(attrs, [:token])
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Argon2.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end

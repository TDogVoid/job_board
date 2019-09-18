defmodule JobBoard.AccountsTest do
  use JobBoard.DataCase
  import JobBoard.TestHelpers

  alias JobBoard.Accounts.User
  alias JobBoard.Accounts

  describe "Users" do
    @valid_attrs %{name: "some user", company: "some company", verified: true, credential: %{email: "some@user.com", password: "some password" }}
    @invalid_attrs %{name: nil, company: nil, verified: true, credential: %{email: nil, password: nil }}
    test "list_users/0 returns all users" do
      {:ok, user} = create_user()
      list = Accounts.list_users()
      |> Repo.preload(:credential)

      # clear password
      c = Map.put(user.credential, :password, nil)
      user = Map.put(user, :credential, c)
      assert list == [user]
    end

    test "get_user/1 returns a user" do
      {:ok, user} = create_user()
      u = Accounts.get_user(user.id)
      |> Repo.preload(:credential)

      # clear password
      c = Map.put(user.credential, :password, nil)
      user = Map.put(user, :credential, c)

      assert user == u
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "get_by/1 returns user" do
      {:ok, user} = create_user()

      #clear password
      c = Map.put(user.credential, :password, nil)
      user = Map.put(user, :credential, c)

      assert user == Accounts.get_by(id: user.id) |> Repo.preload(:credential)
    end

    test "insert_user/1 inserts user" do
      changeset = %User{}
      |> User.register_direct_params(@valid_attrs)

      assert {:ok, %User{} = user} = Accounts.insert_user(changeset)
    end

    test "mark_as_verified/1 marks user as verified" do
      {:ok, user} = create_user()
      {:ok, user} = Accounts.mark_as_verified(user)
      assert user.verified
    end

    test "remove_token/1 removes token" do
      {:ok, user} = create_user()
      Accounts.set_token(user)
      user = Accounts.get_user(user.id) #get user after token set
      |> Repo.preload(:credential)
      Accounts.remove_token(user)
      user = Accounts.get_user(user.id) #get user after token removed
      |> Repo.preload(:credential)
      assert user.credential.token == nil
    end
  end


  describe "credentials" do
    alias JobBoard.Accounts.Credential

    @valid_attrs %{email: "some@email.com", password: "some password_has"}
    @update_attrs %{email: "someupdated@email.com", password: "some updated password_has"}
    @invalid_attrs %{email: nil, password: nil}
    @invalid_password_confirm %{email: "some@email.com", password: "some password_has", password_confirmation: "password"}
    @invalid_email %{email: "invalid", password: "password"}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

        %{credential | password: nil}  # clear password
    end



    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Accounts.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Accounts.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Accounts.create_credential(@valid_attrs)
      assert credential.email == "some@email.com"
      assert checkpw(@valid_attrs.password, credential.password_hash )
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_attrs)
    end

    test "create_credential/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_email)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, credential} = Accounts.update_credential(credential, @update_attrs)
      assert %Credential{} = credential
      assert credential.email == "someupdated@email.com"
      assert checkpw(@update_attrs.password, credential.password_hash )
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_credential(credential, @invalid_attrs)
      assert credential == Accounts.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Accounts.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end

    test "changeset is invalid if password and confirmation do not match" do
      {_error, changeset} = Accounts.create_credential(@invalid_password_confirm)
      refute changeset.valid?
      {message, _} = changeset.errors[:password_confirmation]
      assert message == "does not match password!"
    end

    test "authenticate_by_email_and_pass/2 returns user" do
      {:ok, user} = create_user()

      assert {:ok, %User{} = user} = Accounts.authenticate_by_email_and_pass(user.credential.email, user.credential.password)
    end

    test "authenticate_by_email_and_pass/2 returns unauthorized with invalid password" do
      {:ok, user} = create_user()

      assert {:error, :unauthorized} = Accounts.authenticate_by_email_and_pass(user.credential.email, "user.credential.password")
    end

    test "authenticate_by_email_and_pass/2 returns error with unauthorized with invalid email" do
      {:ok, _} = create_user()

      assert {:error, :unauthorized} = Accounts.authenticate_by_email_and_pass("user.credential.email", "user.credential.password")
    end
  end

  defp checkpw(given_pass, pass_hash) do
    Comeonin.Argon2.checkpw(given_pass, pass_hash)
  end



  describe "roles" do
    alias JobBoard.Accounts.Role

    @valid_attrs %{name: "some role", can_edit_others_job: true}
    @update_attrs %{name: "updated role", can_edit_others_job: false}
    @invalid_attrs %{name: nil, can_edit_others_job: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Accounts.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Accounts.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Accounts.create_role(@valid_attrs)
      assert role.can_edit_others_job == true
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, role} = Accounts.update_role(role, @update_attrs)
      assert %Role{} = role
      assert role.can_edit_others_job == false
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_role(role, @invalid_attrs)
      assert role == Accounts.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Accounts.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_role(role)
    end
  end
end

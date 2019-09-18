defmodule JobBoardWeb.UserControllerTest do
  use JobBoardWeb.ConnCase

  import JobBoard.TestHelpers

  @user_attrs %{name: "some user", company: "some company", credential: %{email: "some@user.com", password: "some password", password_confirmation: "some password" }, agree_terms: "true"}
  @update_attrs %{name: "updated name", company: "updated company", credential: %{email: "updated_some@user.com", password: "some updated password", password_confirmation: "some updated password" }}
  @invalid_attrs %{name: nil, company: nil, credential: %{email: nil, password: nil }}
  @short_password %{name: "short user", company: "short company", credential: %{email: "short@user.com", password: "short", password_confirmation: "short" }}

  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  describe "index" do
    test "admin access list all users", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "List of users"
    end

    test "deny list all users non-admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, user_path(conn, :index)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end

    test "list all users denied if not logged in", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_path(conn, :new)

      assert html_response(conn, 200) =~ "New User"
    end
  end


  describe "create user" do
    test "with valid data", %{conn: conn} do
      create_user_role() # needs to be created before user can be created
      conn = post conn, user_path(conn, :create), user: @user_attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "User Succesfully Created"

    end

    test "with invalid data", %{conn: conn} do
      create_user_role() # needs to be created before user can be created
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end

    test "short password", %{conn: conn} do
      create_user_role() # needs to be created before user can be created
      conn = post conn, user_path(conn, :create), user: @short_password
      assert html_response(conn, 200) =~ "should be at least 6 character"
    end
  end

  describe "show user" do
    setup [:create_users]

    test "renders show page for owner", %{conn: conn, user: user} do
      conn = signin(conn)
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "User"
    end

    test "renders error when other user view page", %{conn: conn, user: user} do
      conn = signin_other(conn)
      conn = get conn, user_path(conn, :show, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end

    test "renders show page for admin", %{conn: conn, user: user} do
      conn = signin_admin(conn)
      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "User"
    end

    test "renders error when not logged in", %{conn: conn, user: user} do
      conn = get conn, user_path(conn, :show, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end
  end

  describe "edit user" do
    setup [:create_users]

    test "by owner renders form for editing user", %{conn: conn, user: user} do
      conn = signin(conn)

      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "by other renders error", %{conn: conn, user: user} do
      conn = signin_other(conn)

      conn = get conn, user_path(conn, :edit, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end

    test "by admin renders form for editing job", %{conn: conn, user: user} do
      conn = signin_admin(conn)

      conn = get conn, user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end

  end

  describe "update user" do
    setup [:create_users]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = signin(conn)
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = signin(conn)
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "change role id as user doesn't work", %{conn: conn, user: user} do
      conn = signin(conn)
      role = role_fixture(:role)
      attrs = @update_attrs
      |> Map.put("role_id", role.id)

      conn = put conn, user_path(conn, :update, user), user: attrs
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "updated name"
      assert conn.assigns.user.role_id != role.id
    end

    test "change role id as admin", %{conn: conn, user: user} do
      conn = signin_admin(conn)
      role = role_fixture(:role)
      attrs = @update_attrs
      |> Map.put("role_id", role.id)

      conn = put conn, user_path(conn, :update, user), user: attrs
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "updated name"

      assert conn.assigns.user.role_id == role.id
    end

  end

  describe "delete user" do
    setup [:create_users]

    test "owner", %{conn: conn, user: user} do
      conn = signin(conn)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "User deleted successfully."

      assert_error_sent 404, fn ->
        get conn, job_path(conn, :show, user)
      end
    end

    test "renders error when trying to delete other user", %{conn: conn, user: user} do
      conn = signin_other(conn)

      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end

    test "when admin", %{conn: conn, user: user} do
      conn = signin_admin(conn)
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "User deleted successfully."

      assert_error_sent 404, fn ->
        get conn, job_path(conn, :show, user)
      end
    end

    test "renders error when not logged in", %{conn: conn, user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end
  end
end

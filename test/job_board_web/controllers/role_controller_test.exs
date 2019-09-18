defmodule JobBoardWeb.RoleControllerTest do
  use JobBoardWeb.ConnCase

  alias JobBoard.Accounts
  import JobBoard.TestHelpers

  @create_attrs %{name: "some role", can_edit_others_job: true, can_delete_others_job: true, can_view_user_list: true, can_edit_other_users: true, can_delete_other_users: true, can_promote_users: true}
  @update_attrs %{name: "some role", can_edit_others_job: false, can_delete_others_job: false, can_view_user_list: false, can_edit_other_users: false, can_delete_other_users: false, can_promote_users: false}
  @invalid_attrs %{name: "some role", can_edit_others_job: nil, can_delete_others_job: nil, can_view_user_list: nil, can_edit_other_users: nil, can_delete_other_users: nil, can_promote_users: nil}

  def fixture(:role) do
    {:ok, role} = Accounts.create_role(@create_attrs)
    role
  end

  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = signin_admin(conn)

      conn = get conn, role_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Roles"
    end

    test "deny lists all roles if not logged in", %{conn: conn} do
      conn = get conn, role_path(conn, :index)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny lists all roles if not admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, role_path(conn, :index)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  describe "new role" do
    test "renders form", %{conn: conn} do
      conn = signin_admin(conn)

      conn = get conn, role_path(conn, :new)
      assert html_response(conn, 200) =~ "New Role"
    end

    test "deny role form if not logged in", %{conn: conn} do
      conn = get conn, role_path(conn, :new)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny role form if not admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, role_path(conn, :new)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = signin_admin(conn)

      conn = post conn, role_path(conn, :create), role: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == role_path(conn, :show, id)

      conn = get conn, role_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Role"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = signin_admin(conn)

      conn = post conn, role_path(conn, :create), role: @invalid_attrs
      assert html_response(conn, 200) =~ "New Role"
    end

    test "deny create role if not logged in", %{conn: conn} do
      conn = post conn, role_path(conn, :create), role: @create_attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny create role if not admin", %{conn: conn} do
      conn = signin(conn)
      conn = post conn, role_path(conn, :create), role: @create_attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  describe "edit role" do
    setup [:create_role]

    test "renders form for editing chosen role", %{conn: conn, role: role} do
      conn = signin_admin(conn)

      conn = get conn, role_path(conn, :edit, role)
      assert html_response(conn, 200) =~ "Edit Role"
    end

    test "deny edit role if not logged in", %{conn: conn, role: role} do
      conn = get conn, role_path(conn, :edit, role)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny edit role if not admin", %{conn: conn, role: role} do
      conn = signin(conn)
      conn = get conn, role_path(conn, :edit, role)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  describe "update role" do
    setup [:create_role]

    test "redirects when data is valid", %{conn: conn, role: role} do
      conn = signin_admin(conn)

      conn = put conn, role_path(conn, :update, role), role: @update_attrs
      assert redirected_to(conn) == role_path(conn, :show, role)

      conn = get conn, role_path(conn, :show, role)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn = signin_admin(conn)

      conn = put conn, role_path(conn, :update, role), role: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Role"
    end

    test "deny update role if not logged in", %{conn: conn, role: role} do
      conn = put conn, role_path(conn, :update, role), role: @update_attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny update role if not admin", %{conn: conn, role: role} do
      conn = signin(conn)
      conn = put conn, role_path(conn, :update, role), role: @update_attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn = signin_admin(conn)

      conn = delete conn, role_path(conn, :delete, role)
      assert redirected_to(conn) == role_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, role_path(conn, :show, role)
      end
    end

    test "deny delete role if not logged in", %{conn: conn, role: role} do
      conn = delete conn, role_path(conn, :delete, role)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "deny delete role if not admin", %{conn: conn, role: role} do
      conn = signin(conn)
      conn = delete conn, role_path(conn, :delete, role)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Unauthorized"
    end
  end

  defp create_role(_) do
    role = fixture(:role)
    {:ok, role: role}
  end
end

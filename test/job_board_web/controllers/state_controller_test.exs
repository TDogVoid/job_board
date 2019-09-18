defmodule JobBoardWeb.StateControllerTest do
  use JobBoardWeb.ConnCase

  import JobBoard.TestHelpers

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  describe "index" do
    test "lists all states", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get conn, state_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing States"
    end

    test "deny lists all states non admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, state_path(conn, :index)
      assert_unauthorized(conn)
    end

    test "deny lists all states not logged in", %{conn: conn} do
      conn = get conn, state_path(conn, :index)
      assert_not_logged_in(conn)
    end
  end

  describe "new state" do
    test "renders form", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get conn, state_path(conn, :new)
      assert html_response(conn, 200) =~ "New State"
    end

    test "renders error on form not logged in", %{conn: conn} do
      conn = get conn, state_path(conn, :new)
      assert_not_logged_in(conn)
    end

    test "renders error on form non admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, state_path(conn, :new)
      assert_unauthorized(conn)
    end
  end

  describe "create state" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = signin_admin(conn)
      conn = post conn, state_path(conn, :create), state: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == state_path(conn, :show, id)

      conn = get conn, state_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show State"
    end

    test "error when not admin", %{conn: conn} do
      conn = signin(conn)
      conn = post conn, state_path(conn, :create), state: @create_attrs

      assert_unauthorized(conn)
    end

    test "error when not logged in", %{conn: conn} do
      conn = post conn, state_path(conn, :create), state: @create_attrs

      assert_not_logged_in(conn)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = signin_admin(conn)
      conn = post conn, state_path(conn, :create), state: @invalid_attrs
      assert html_response(conn, 200) =~ "New State"
    end
  end

  describe "edit state" do
    setup [:create_state]

    test "renders form for editing chosen state", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      conn = get conn, state_path(conn, :edit, state)
      assert html_response(conn, 200) =~ "Edit State"
    end

    test "renders error not admin", %{conn: conn, state: state} do
      conn = signin(conn)
      conn = get conn, state_path(conn, :edit, state)
      assert_unauthorized(conn)
    end

    test "renders error not logged in", %{conn: conn, state: state} do
      conn = get conn, state_path(conn, :edit, state)
      assert_not_logged_in(conn)
    end
  end

  describe "update state" do
    setup [:create_state]

    test "redirects when data is valid", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      conn = put conn, state_path(conn, :update, state), state: @update_attrs
      assert redirected_to(conn) == state_path(conn, :show, state)

      conn = get conn, state_path(conn, :show, state)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "error when not admin", %{conn: conn, state: state} do
      conn = signin(conn)
      conn = put conn, state_path(conn, :update, state), state: @update_attrs
      assert_unauthorized(conn)
    end

    test "error when not logged in", %{conn: conn, state: state} do
      conn = put conn, state_path(conn, :update, state), state: @update_attrs
      assert_not_logged_in(conn)
    end

    test "renders errors when data is invalid", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      conn = put conn, state_path(conn, :update, state), state: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit State"
    end
  end

  describe "delete state" do
    setup [:create_state]

    test "deletes chosen state", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      conn = delete conn, state_path(conn, :delete, state)
      assert redirected_to(conn) == state_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, state_path(conn, :show, state)
      end
    end

    test "error when not logged in", %{conn: conn, state: state} do
      conn = delete conn, state_path(conn, :delete, state)
      assert_not_logged_in(conn)
    end

    test "error when not admin", %{conn: conn, state: state} do
      conn = signin(conn)
      conn = delete conn, state_path(conn, :delete, state)
      assert_unauthorized(conn)
    end
  end

  defp assert_unauthorized(conn) do
    assert redirected_to(conn) == job_path(conn, :index)

    conn = get conn, job_path(conn, :index)
    assert html_response(conn, 200) =~ "Unauthorized"
  end
  defp assert_not_logged_in(conn) do
    assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
  end
end

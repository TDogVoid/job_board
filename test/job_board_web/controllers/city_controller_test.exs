defmodule JobBoardWeb.CityControllerTest do
  use JobBoardWeb.ConnCase

  import JobBoard.TestHelpers

  @create_attrs %{name: "some name", zipcode: 42, lat: 31, long: 12}
  @update_attrs %{name: "some updated name", zipcode: 43, lat: 32, long: 22}
  @invalid_attrs %{name: nil, zipcode: nil, lat: nil, long: nil}

  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  describe "index" do
    test "lists all cities with admin", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get conn, city_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cities"
    end

    test "deny lists all cities not logged it", %{conn: conn} do
      conn = get conn, city_path(conn, :index)
      assert_not_logged_in(conn)
    end

    test "deny lists all cities not admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, city_path(conn, :index)
      assert_unauthorized(conn)
    end
  end

  describe "new city" do
    test "renders form with admin", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get conn, city_path(conn, :new)
      assert html_response(conn, 200) =~ "New City"
    end

    test "renders error on form not logged in", %{conn: conn} do
      conn = get conn, city_path(conn, :new)
      assert_not_logged_in(conn)
    end

    test "renders error on form non admin", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, city_path(conn, :new)
      assert_unauthorized(conn)
    end
  end

  describe "create city" do
    setup [:create_state]
    test "redirects to show when data is valid", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      attrs = Map.put(@create_attrs, :state_id, state.id)
      conn = post conn, city_path(conn, :create), city: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == city_path(conn, :show, id)

      conn = get conn, city_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show City"
    end

    test "renders errors when data is invalid", %{conn: conn, state: state} do
      conn = signin_admin(conn)
      attrs = Map.put(@invalid_attrs, :state_id, state.id)
      conn = post conn, city_path(conn, :create), city: attrs
      assert html_response(conn, 200) =~ "New City"
    end

    test "renders errors when not logged in", %{conn: conn, state: state} do
      attrs = Map.put(@create_attrs, :state_id, state.id)
      conn = post conn, city_path(conn, :create), city: attrs
      assert_not_logged_in(conn)
    end

    test "renders errors when not admin", %{conn: conn, state: state} do
      conn = signin(conn)
      attrs = Map.put(@create_attrs, :state_id, state.id)
      conn = post conn, city_path(conn, :create), city: attrs
      assert_unauthorized(conn)
    end
  end

  describe "edit city" do
    setup [:create_city]

    test "renders form for editing chosen city when admin", %{conn: conn, city: city} do
      conn = signin_admin(conn)
      conn = get conn, city_path(conn, :edit, city)
      assert html_response(conn, 200) =~ "Edit City"
    end

    test "renders error when not admin", %{conn: conn, city: city} do
      conn = signin(conn)
      conn = get conn, city_path(conn, :edit, city)
      assert_unauthorized(conn)
    end

    test "renders error when not logged in", %{conn: conn, city: city} do
      conn = get conn, city_path(conn, :edit, city)
      assert_not_logged_in(conn)
    end
  end

  describe "update city" do
    setup [:create_city]

    test "redirects when data is valid", %{conn: conn, city: city} do
      conn = signin_admin(conn)
      conn = put conn, city_path(conn, :update, city), city: @update_attrs
      assert redirected_to(conn) == city_path(conn, :show, city)

      conn = get conn, city_path(conn, :show, city)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, city: city} do
      conn = signin_admin(conn)
      conn = put conn, city_path(conn, :update, city), city: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit City"
    end

    test "error when not admin", %{conn: conn, city: city} do
      conn = signin(conn)
      conn = put conn, city_path(conn, :update, city), city: @update_attrs
      assert_unauthorized(conn)
    end

    test "error when not logged in", %{conn: conn, city: city} do
      conn = put conn, city_path(conn, :update, city), city: @update_attrs
      assert_not_logged_in(conn)
    end
  end

  describe "delete city" do
    setup [:create_city]

    test "deletes chosen city", %{conn: conn, city: city} do
      conn = signin_admin(conn)
      conn = delete conn, city_path(conn, :delete, city)
      assert redirected_to(conn) == city_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, city_path(conn, :show, city)
      end
    end

    test "renders error when not admin", %{conn: conn, city: city} do
      conn = signin(conn)
      conn = delete conn, city_path(conn, :delete, city)
      assert_unauthorized(conn)
    end

    test "error when not logged in", %{conn: conn, city: city} do
      conn = delete conn, city_path(conn, :delete, city)
      assert_not_logged_in(conn)
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

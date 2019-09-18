defmodule JobBoardWeb.ConfigControllerTest do
  use JobBoardWeb.ConnCase

  alias JobBoard.Siteconfigs
  import JobBoard.TestHelpers

  @create_attrs %{post_price: 42, site_name: "some site_name", site_slug: "some site_slug", ucon: 42}
  @update_attrs %{post_price: 43, site_name: "some updated site_name", site_slug: "some updated site_slug", ucon: 43}
  @invalid_attrs %{post_price: nil, site_name: nil, site_slug: nil, ucon: nil}

  def fixture(:config) do
    {:ok, config} = Siteconfigs.create_config(@create_attrs)
    config
  end

  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  describe "index" do
    test "lists all configs", %{conn: conn} do
      conn = signin_admin(conn)
      conn = get(conn, config_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Configs"
    end
  end


  describe "edit config" do
    setup [:create_config]

    test "renders form for editing chosen config", %{conn: conn, config: config} do
      conn = signin_admin(conn)
      conn = get(conn, config_path(conn, :edit, config))
      assert html_response(conn, 200) =~ "Edit Config"
    end
  end

  describe "update config" do
    setup [:create_config]

    test "redirects when data is valid", %{conn: conn, config: config} do
      conn = signin_admin(conn)
      conn = put(conn, config_path(conn, :update, config), config: @update_attrs)
      assert redirected_to(conn) == config_path(conn, :show, config)

      conn = get(conn, config_path(conn, :show, config))
      assert html_response(conn, 200) =~ "some updated site_name"
    end

    test "renders errors when data is invalid", %{conn: conn, config: config} do
      conn = signin_admin(conn)
      conn = put(conn, config_path(conn, :update, config), config: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Config"
    end
  end

  defp create_config(_) do
    config = fixture(:config)
    {:ok, config: config}
  end
end

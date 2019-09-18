defmodule JobBoard.SiteconfigsTest do
  use JobBoard.DataCase

  alias JobBoard.Siteconfigs

  describe "configs" do
    alias JobBoard.Siteconfigs.Config

    @valid_attrs %{post_price: 42, site_name: "some site_name", site_slug: "some site_slug", ucon: 42}
    @update_attrs %{post_price: 43, site_name: "some updated site_name", site_slug: "some updated site_slug", ucon: 43}
    @invalid_attrs %{post_price: nil, site_name: nil, site_slug: nil, ucon: nil}

    def config_fixture(attrs \\ %{}) do
      {:ok, config} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Siteconfigs.create_config()

      config
    end

    test "list_configs/0 returns all configs" do
      config = config_fixture()
      assert Siteconfigs.list_configs() == [config]
    end

    test "get_config!/1 returns the config with given id" do
      config = config_fixture()
      assert Siteconfigs.get_config!(config.id) == config
    end

    test "create_config/1 with valid data creates a config" do
      assert {:ok, %Config{} = config} = Siteconfigs.create_config(@valid_attrs)
      assert config.post_price == 42
      assert config.site_name == "some site_name"
      assert config.site_slug == "some site_slug"
      assert config.ucon == 42
    end

    test "create_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Siteconfigs.create_config(@invalid_attrs)
    end

    test "update_config/2 with valid data updates the config" do
      config = config_fixture()
      assert {:ok, %Config{} = config} = Siteconfigs.update_config(config, @update_attrs)
      assert config.post_price == 43
      assert config.site_name == "some updated site_name"
      assert config.site_slug == "some updated site_slug"
      assert config.ucon == 43
    end

    test "update_config/2 with invalid data returns error changeset" do
      config = config_fixture()
      assert {:error, %Ecto.Changeset{}} = Siteconfigs.update_config(config, @invalid_attrs)
      assert config == Siteconfigs.get_config!(config.id)
    end

    test "delete_config/1 deletes the config" do
      config = config_fixture()
      assert {:ok, %Config{}} = Siteconfigs.delete_config(config)
      assert_raise Ecto.NoResultsError, fn -> Siteconfigs.get_config!(config.id) end
    end

    test "change_config/1 returns a config changeset" do
      config = config_fixture()
      assert %Ecto.Changeset{} = Siteconfigs.change_config(config)
    end
  end
end

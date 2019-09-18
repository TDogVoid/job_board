defmodule JobBoard.CitiesTest do
  use JobBoard.DataCase

  alias JobBoard.Cities

  describe "cities" do
    alias JobBoard.Cities.City

    @valid_attrs %{name: "some name", zipcode: 42,state_id: nil, lat: 41.23, long: 43.32}
    @update_attrs %{name: "some updated name", zipcode: 43, lat: 43.23, long: 43.23}
    @invalid_attrs %{name: nil, zipcode: nil, lat: nil, long: nil}

    @state_attrs %{name: "some name"}
    def state_fixture(:state) do
      {:ok, state} = JobBoard.States.create_state(@state_attrs)
      state
    end



    def city_fixture(attrs \\ %{}) do
      state = state_fixture(:state).id
      c = %{@valid_attrs | state_id: state}
      {:ok, city} =
        attrs
        |> Enum.into(c)
        |> Cities.create_city()

      city
    end

    test "list_cities/0 returns all cities" do
      city = city_fixture()
      |> Map.put(:lat, nil)
      |> Map.put(:long, nil)
      assert Cities.list_cities() == [city]
    end

    test "get_city!/1 returns the city with given id" do
      city = city_fixture()
      |> Map.put(:lat, nil)
      |> Map.put(:long, nil)
      assert Cities.get_city!(city.id) == city
    end

    test "create_city/1 with valid data creates a city" do
      state = state_fixture(:state).id
      c = %{@valid_attrs | state_id: state}
      assert {:ok, %City{} = city} = Cities.create_city(c)
      assert city.name == "some name"
      assert city.zipcode == 42
      assert city.geom == %Geo.Point{coordinates: {@valid_attrs.lat, @valid_attrs.long}, srid: 4326}
    end

    test "create_city/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cities.create_city(@invalid_attrs)
    end

    test "update_city/2 with valid data updates the city" do
      city = city_fixture()
      assert {:ok, city} = Cities.update_city(city, @update_attrs)
      assert %City{} = city
      assert city.name == "some updated name"
      assert city.zipcode == 43
      assert city.geom == %Geo.Point{coordinates: {@update_attrs.long, @update_attrs.lat}, srid: 4326}
    end

    test "update_city/2 with invalid data returns error changeset" do
      city = city_fixture()
      assert {:error, %Ecto.Changeset{}} = Cities.update_city(city, @invalid_attrs)
      city = Map.put(city, :lat, nil)
      |> Map.put(:long, nil)
      assert city == Cities.get_city!(city.id)
    end

    test "delete_city/1 deletes the city" do
      city = city_fixture()
      assert {:ok, %City{}} = Cities.delete_city(city)
      assert_raise Ecto.NoResultsError, fn -> Cities.get_city!(city.id) end
    end

    test "change_city/1 returns a city changeset" do
      city = city_fixture()
      assert %Ecto.Changeset{} = Cities.change_city(city)
    end
  end
end

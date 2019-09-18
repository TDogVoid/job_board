defmodule JobBoardWeb.CityController do
  use JobBoardWeb, :controller

  alias JobBoard.Repo
  alias JobBoard.Cities
  alias JobBoard.Cities.City

  plug JobBoardWeb.Plugs.RequireAuth
  plug JobBoardWeb.Plugs.RequireAdmin

  def index(conn, _params) do
    cities = Cities.list_cities()
    |> Repo.preload(:state)
    render(conn, "index.html", cities: cities, pagetitle: "City List")
  end

  def new(conn, _params) do
    changeset = Cities.change_city(%City{} |> Repo.preload(:state))
    states = JobBoard.States.list_states()

    render(conn, "new.html", changeset: changeset, states: states, pagetitle: "New City")
  end

  def create(conn, %{"city" => city_params}) do
    case Cities.create_city(city_params) do
      {:ok, city} ->
        conn
        |> put_flash(:info, "City created successfully.")
        |> redirect(to: Routes.city_path(conn, :show, city))
      {:error, %Ecto.Changeset{} = changeset} ->
        states = JobBoard.States.list_states()
        render(conn, "new.html", changeset: changeset, states: states, pagetitle: "New City")
    end
  end

  def show(conn, %{"id" => id}) do
    city = Cities.get_city!(id)
    |> Repo.preload(:state)
    render(conn, "show.html", city: city, pagetitle: city.name)
  end

  def edit(conn, %{"id" => id}) do
    city = Cities.get_city!(id)
    |> Repo.preload(:state)

    point = Geo.JSON.encode!(city.geom)
    [lat | tail]= point["coordinates"]
    [long | _] = tail

    states = JobBoard.States.list_states()
    changeset = Cities.change_city(city)
    |> Ecto.Changeset.put_change(:lat, lat)
    |> Ecto.Changeset.put_change(:long, long)
    render(conn, "edit.html", city: city, changeset: changeset, states: states, pagetitle: "Edit City")
  end

  def update(conn, %{"id" => id, "city" => city_params}) do
    city = Cities.get_city!(id)

    case Cities.update_city(city, city_params) do
      {:ok, city} ->
        conn
        |> put_flash(:info, "City updated successfully.")
        |> redirect(to: Routes.city_path(conn, :show, city))
      {:error, %Ecto.Changeset{} = changeset} ->
        states = JobBoard.States.list_states()
        render(conn, "edit.html", city: city, changeset: changeset, states: states, pagetitle: "Edit City")
    end
  end

  def delete(conn, %{"id" => id}) do
    city = Cities.get_city!(id)
    {:ok, _city} = Cities.delete_city(city)

    conn
    |> put_flash(:info, "City deleted successfully.")
    |> redirect(to: Routes.city_path(conn, :index))
  end
end

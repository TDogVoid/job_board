defmodule JobBoard.Cities.City do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cities" do
    field :name, :string
    field :zipcode, :integer
    belongs_to :state, JobBoard.States.State
    field :lat, :float, virtual: true
    field :long, :float, virtual: true
    field :geom, Geo.PostGIS.Geometry

    timestamps()
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name, :zipcode, :state_id, :lat, :long])
    |> validate_required([:name, :zipcode, :state_id, :lat, :long])
    |> make_geom()
  end

  defp make_geom(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{long: long, lat: lat}} ->
        put_change(changeset, :geom, %Geo.Point{coordinates: {lat, long}, srid: 4326})
      _ ->
        changeset
    end
  end
end

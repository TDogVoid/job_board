
defmodule FixCords do
  alias JobBoard.Cities.City
  alias JobBoard.Cities
  def fix(filename) do
    case File.read(filename) do
        {:ok, json} ->
            cities = Poison.decode!(json, as: [%City{}])
            Enum.each(cities, fn(city) ->
              dbcity = Cities.get_by(zipcode: city.zipcode)
              params = %{lat: city.lat, long: city.long}

              case Cities.update_city(dbcity, params) do
                {:ok, city} ->
                  IO.inspect("fixed city #{city.name}")
                {:error, %Ecto.Changeset{} = changeset} ->

                  IO.inspect("===========================")
                  IO.inspect(changeset)
                  IO.inspect("===========================")
              end

            end)

        {:error, reason} ->
            IO.inspect(reason)
    end
  end
end

FixCords.fix("priv/repo/citydata.json")

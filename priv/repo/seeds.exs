# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     JobBoard.Repo.insert!(%JobBoard.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias JobBoard.Accounts
alias JobBoard.States
alias JobBoard.Repo

JobBoard.Siteconfigs.create_config()

Accounts.create_role(%{name: "User"})

{:ok, role} = Accounts.create_role(%{name: "Admin Role", admin: true})


Accounts.register_user_direct_params(%{name: "terrence", company: "Ohio Nurse Jobs",
    credential: %{email: "user@user.com", password: "password" },
    role_id: role.id})

States.create_state(%{name: "Ohio"})

defmodule JsonCity do
    use Ecto.Schema


    schema "cities" do
        field :name, :string
        field :zipcode, :integer
        field :state, :string
        field :lat, :float
        field :long, :float
    end
end

defmodule Cities do
    alias JobBoard.Cities.City

    def get_cities(filename) do
        case File.read(filename) do
            {:ok, json} ->
                cities = Poison.decode!(json, as: [%JsonCity{}])
                Enum.each(cities, fn(city) ->
                    state_id = JobBoard.States.get_by(name: city.state).id
                    geo = %Geo.Point{coordinates: {city.lat, city.long}, srid: 4326}

                    struct(City, Map.from_struct(city))
                    |> Map.put(:state, nil)
                    |> Map.put(:geom, geo)
                    |> Map.put(:state_id, state_id)
                    |> Repo.insert()
                end)

            {:error, reason} ->
                IO.inspect(reason)
        end
    end
end


Cities.get_cities("priv/repo/citydata.json")

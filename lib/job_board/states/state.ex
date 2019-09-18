defmodule JobBoard.States.State do
  use Ecto.Schema
  import Ecto.Changeset


  schema "states" do
    field :name, :string
    has_many :cities, JobBoard.Cities.City

    timestamps()
  end

  @doc false
  def changeset(state, attrs) do
    state
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

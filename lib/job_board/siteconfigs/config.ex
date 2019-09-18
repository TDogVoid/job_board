defmodule JobBoard.Siteconfigs.Config do
  use Ecto.Schema
  import Ecto.Changeset


  schema "configs" do
    field :post_price, :integer, default: 0
    field :site_name, :string, default: "Job Board"
    field :site_slug, :string, default: "Find Jobs"
    field :ucon, :integer, unique: true, default: 0

    timestamps()
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:ucon, :site_name, :post_price, :site_slug])
    |> validate_required([:ucon, :site_name, :post_price, :site_slug])
  end
end

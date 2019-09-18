defmodule JobBoard.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]


  schema "jobs" do
    field :title, :string
    field :link, :string
    field :company, :string
    field :payment_id, :string
    field :receipt_number, :string
    belongs_to :user, JobBoard.Accounts.User
    belongs_to :city, JobBoard.Cities.City
    field :zipcode, :integer, virtual: true
    field :stripeToken, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :link, :company, :zipcode, :city_id, :stripeToken, :payment_id, :receipt_number])
    |> validate_required([:title, :link, :zipcode])
    |> set_city()
    |> validate_required([:title, :link, :city_id])
    |> validate_link(:link)
  end

  def new_changeset(job, attrs) do
    changeset(job, attrs)
    |> validate_required([:stripeToken])
  end

  def add_payment_id(changeset, id) do
    changeset
    |> put_change(:payment_id, id)
  end

  def add_receipt_number(changeset, id) do
    changeset
    |> put_change(:receipt_number, id)
  end

  defp validate_link(changeset, link) do
    validate_change(changeset, link, fn _, url ->
      case valid_url(url) do
        true -> []
        false -> [link: "Not a valid Link"]
      end
    end)
  end

  defp valid_url(link) do
    %URI{scheme: scheme, host: host} = URI.parse(link)
    #got to be a cleaner way of writting below
    if scheme && host do
      true
    else
      false
    end
  end

  def search(query, search_term) do
    wildcard_search = "%#{search_term}%"

    from job in query,
      join: user in assoc(job, :user),
      join: city in assoc(job, :city),

      where: ilike(job.title, ^wildcard_search),
      or_where: ilike(job.company, ^wildcard_search),
      or_where: ilike(user.company, ^wildcard_search),
      or_where: ilike(city.name, ^wildcard_search),
      preload: [:user]
  end

  defp set_city(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{zipcode: zipcode}} ->
        city = JobBoard.Cities.get_by(zipcode: zipcode)
        case city do
          nil ->
            add_error(changeset, :zipcode, "invalid zipcode or unknown. If zipcode is correct contact us at so we can fix it")
          _ ->
            put_change(changeset, :city_id, city.id)
        end
      _ ->
        changeset
    end
  end
end

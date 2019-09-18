defmodule JobBoard.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias JobBoard.Repo
  alias JobBoard.Cities
  alias JobBoard.Jobs.Job
  alias JobBoard.Pagination
  alias JobBoard.Accounts.User

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  def get_jobs_older_than(datetime) do
    Job
    |> where([j], j.inserted_at < ^datetime)
    |> Repo.all()
  end

  def list_jobs(params) when is_map(params) do
    search_term = get_in(params, ["query"])

    Job
    |> Job.search(search_term)
    |> Repo.all()
  end

  def list_jobs(:paged, page \\ 1, per_page \\ 10) do
    Job
    |> order_by(desc: :inserted_at)
    |> Pagination.page(page, per_page: per_page)
  end

  def list_jobs_params(:paged, params, page \\ 1, per_page \\ 20) when is_map(params) do
    jobs = Cachex.get(:jobs, params)
    case jobs do
      {:ok, nil} ->
        list_jobs_params_from_db(:paged, params, page, per_page)
      {:ok, cache} -> cache
    end
  end

  def list_jobs_params_from_db(:paged, params, page \\ 1, per_page \\ 20) when is_map(params) do
    search_term = get_in(params, ["query"])
    miles=get_in(params, ["miles"])
    zipcode=get_in(params, ["zipcode"])
    jobs =
      if (zipcode != "" and miles != "") && (zipcode != nil and miles != nil) do
        jq = Job
        |> Job.search(search_term)
        |> get_within(zipcode, miles)

        case jq do
          {:ok, query} ->
            query
            |> order_by(desc: :inserted_at)
            |> Pagination.page(page, per_page: per_page)
          {:error, query} ->
            query
            |> order_by(desc: :inserted_at)
            |> Pagination.page(page, per_page: per_page, error: "Unknown Zipcode")
        end
      else
        Job
        |> Job.search(search_term)
        |> order_by(desc: :inserted_at)
        |> Pagination.page(page, per_page: per_page)
      end
    Cachex.put(:jobs, params, jobs)
    jobs
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id) do
    case Cachex.get!(:jobs, id) do
      nil -> get_job_from_db!(id)
      job -> job
    end
  end

  def get_job_from_db!(id) do
    job = Repo.get!(Job, id)
    Cachex.put(:jobs, id, job)
    job
  end

    @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job(id), do: Repo.get(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    j = job
    |> Job.changeset(attrs)
    |> Repo.update()

    Cachex.reset(:jobs)

    j
  end

  @doc """
  Deletes a Job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    d = Repo.delete(job)
    Cachex.reset(:jobs)
    d
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{source: %Job{}}

  """
  def change_job(%Job{} = job) do
    Job.changeset(job, %{})
  end

  @doc """
  Same as Repo.insert(changeset)

  """
  def insert_job(changeset) do
    i = Repo.insert(changeset)
    Cachex.reset(:jobs)
    i
  end

  def get_by(clauses) do
    Repo.get_by(Job, clauses)
  end

  def get_by_link_limit(link, limit) do
    Job
    |> where([j], j.link == ^link)
    |> limit(^limit)
    |> Repo.one()
  end

  def page_of_jobs(user, page \\ 1, per_page \\ 10)
  def page_of_jobs(%User{} = x, y, z), do: page_of_jobs(x.id, y, z)
  def page_of_jobs(user_id, page, per_page) do
    Job
    |> order_by(desc: :inserted_at)
    |> where(user_id: ^user_id)
    |> Pagination.page(page, per_page: per_page)
  end



  def get_within(query, zipcode, miles) when is_binary(zipcode) do
    get_within(query, String.to_integer(zipcode), miles)
  end

  def get_within(query, zipcode, miles) when is_binary(miles) do
    get_within(query, zipcode, String.to_integer(miles))
  end

  def get_within(query, zipcode, miles) do
    # gets all cities within area and then adds test to query
    case Cities.get_within(zipcode, miles) do
      {:ok, cities} ->
        cities_id = for city <- cities do
          city.id
        end

        query = query
        |> where([job], job.city_id in ^cities_id)
        {:ok, query}
      _ ->
        {:error, query}
    end


  end

  def get_jobs_in_city(query, city_id) do
    query
    |> where([job], job.city_id == ^city_id)
  end

  def populate_job_list(jobs) do
    case Cachex.get!(:jobs, jobs) do
      nil -> populate_job_list_from_db(jobs)
      jobs -> jobs
    end
  end

  def populate_job_list_from_db(jobs) do
    j = jobs
    |> Repo.preload(:user)
    |> Repo.preload(:city)
    |> Repo.preload(city: :state)

    Cachex.put!(:jobs, jobs, j)
    j
  end
end

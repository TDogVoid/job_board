defmodule JobBoardWeb.JobController do
  use JobBoardWeb, :controller

  alias JobBoard.Repo
  alias JobBoard.Jobs
  alias JobBoard.Jobs.Job
  alias JobBoard.Stripe
  alias JobBoard.Siteconfigs

  plug JobBoardWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_job_owner when action in [:update, :edit, :delete]

  def index(conn, params) do
    page = params["page"] || 1
    jobs = Jobs.list_jobs_params(:paged, params, page)
    query = params["query"]
    miles = params["miles"]
    zipcode = params["zipcode"]

    jobs = %{jobs | list: Jobs.populate_job_list(jobs.list)}

    render(conn, "index.html", jobs: jobs, query: query, miles: miles, zipcode: zipcode, pagetitle: "Job List")
  end

  def new(conn, _params) do
    user = conn.assigns.current_user
    |> Repo.preload(:role)

    case user.verified do
      true ->
        changeset = Jobs.change_job(%Job{})
        render_new(conn, changeset, user)
      _ ->
        conn
        |> put_flash(:info, "Please verify email before you can create a job")
        |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end

  defp render_new(conn, changeset, user) do
    render(conn, "new.html", changeset: changeset, user: user, pagetitle: "New Job", secure: true)
  end

  def create(conn, %{"job" => job_params}) do
    user = conn.assigns.current_user
    case user.verified do
      true ->
        create_job(conn, user, job_params)
      _ ->
        conn
        |> put_flash(:info, "Please verify email before you can create a job")
        |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end

  defp create_job(conn, user, job_params) do
    user = user
    |> Repo.preload(:role)

      if user.role.post_free || user.role.admin do
        changeset = user
        |> Ecto.build_assoc(:jobs)
        |> Job.changeset(job_params)

        insert_job(conn, user, changeset)
      else
        changeset = user
        |> Ecto.build_assoc(:jobs)
        |> Job.new_changeset(job_params)

        if changeset.valid? do
          process_card(conn, user, changeset)
        else
          # continue on since it's going to stop and render error
          insert_job(conn, user, changeset)
        end
      end
  end

  defp process_card(conn, user, changeset) do
    user = user
    |> Repo.preload(:credential)

    case Stripe.charge(:token, Siteconfigs.get_main().post_price, changeset.changes.stripeToken, user.credential.email) do
      {:ok, res} ->
        case res["status"] do
          "succeeded" ->
            changeset = changeset
            |> Job.add_payment_id(res["id"])
            |> Job.add_receipt_number(res["receipt_number"])

            insert_job(conn, user, changeset)
          _ ->
            user
            |> Repo.preload(:role)

            conn
            |> put_flash(:info, "Failed to charge card")
            |> render_new(changeset, user)
        end
      {:error, res} ->
        user
        |> Repo.preload(:role)

        conn
        |> put_flash(:info, res["message"])
        |> render_new(changeset, user)
    end
  end

  defp insert_job(conn, user, changeset) do
    case Jobs.insert_job(changeset) do
      {:ok, job} ->
        JobBoard.NotifyMe.new_purchase(job)
        |> JobBoard.Mailer.deliver_later

        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: Routes.job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        user
        |> Repo.preload(:role)

        render_new(conn, changeset, user)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    |> Repo.preload(:user)
    |> Repo.preload(:city)
    |> Repo.preload(city: :state)
    render(conn, "show.html", job: job, pagetitle: job.title)
  end

  def edit(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    |> Repo.preload(:city)

    user = conn.assigns.current_user
    |> Repo.preload(:role)

    # so we can see the zipcode job currently being edited
    changeset = Jobs.change_job(job)
    |> Ecto.Changeset.put_change(:zipcode, job.city.zipcode)

    render(conn, "edit.html", job: job, changeset: changeset, user: user, pagetitle: "Edit Job")
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    case Jobs.update_job(job, job_params) do
      {:ok, job} ->

        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: Routes.job_path(conn, :show, job))
      {:error, %Ecto.Changeset{} = changeset} ->
        user = conn.assigns.current_user
        |> Repo.preload(:role)
        render(conn, "edit.html", job: job, changeset: changeset, user: user, pagetitle: "Edit Job")
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    {:ok, _job} = Jobs.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: Routes.job_path(conn, :index))
  end

  def outbound(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)

    conn
    |> redirect(external: job.link)
  end

  defp check_job_owner(%{params: %{"id" => job_id}} = conn, _params) do
    if (conn.assigns.current_user && Jobs.get_job(job_id).user_id == conn.assigns.current_user.id) || conn.assigns.current_user.role.admin do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: Routes.job_path(conn, :index))
      |> halt()
    end
  end
end

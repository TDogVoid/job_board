defmodule JobBoardWeb.JobAPIController do
  use JobBoardWeb, :controller

  alias JobBoard.Jobs
  alias JobBoard.Jobs.Job

  plug JobBoardWeb.Plugs.APIRequireAuth

  def create(conn, %{"job" => job_params}) do
    case Jobs.get_by_link_limit(job_params["link"], 1) do
      nil ->
        conn.assigns.current_user
          |> Ecto.build_assoc(:jobs)
          |> Job.changeset(job_params)
          |> insert_job(conn)
      _ ->
        conn
      |> put_status(:ok)
      |> put_view(JobBoardWeb.JobView)
      |> render("job.json", %{message: "Job Already Exist", job: nil})
    end




  end

  def create(conn, _) do
    conn
    |> put_view(JobBoardWeb.ErrorView)
    |> render("401.json", %{message: "check data"})
  end

  defp insert_job(changeset, conn) do
    case Jobs.insert_job(changeset) do
      {:ok, job} ->
        conn
        |> put_status(:ok)
        |> put_view(JobBoardWeb.JobView)
        |> render("job.json", %{message: "Job Created", job: job})
      {:error, _message} ->
        conn
        |> put_view(JobBoardWeb.ErrorView)
        |> render("401.json", %{message: "check data"})
    end
  end


end

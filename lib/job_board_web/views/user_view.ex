defmodule JobBoardWeb.UserView do
  use JobBoardWeb, :view
  alias JobBoard.Repo

  def is_current_user_admin(conn) do
    user = conn.assigns.current_user
    |> Repo.preload(:role)

    user.role.admin
  end

  def loaded_jobs(job) do
    job
    |> Repo.preload(:user)
  end
end

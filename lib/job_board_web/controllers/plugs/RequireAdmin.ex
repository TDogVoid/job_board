defmodule JobBoardWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller
  alias JobBoard.Repo

  alias JobBoardWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    user = conn.assigns.current_user
    |> Repo.preload(:role)

    if user.role.admin do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: Helpers.job_path(conn, :index))
      |> halt()
    end
  end
end

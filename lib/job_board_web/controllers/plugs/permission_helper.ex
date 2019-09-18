defmodule JobBoardWeb.Plugs.PermissionHelper do
  import Plug.Conn
  import Phoenix.Controller
  alias JobBoardWeb.Router.Helpers

  def unauthorized(conn) do
    conn
    |> put_flash(:error, "Unauthorized")
    |> redirect(to: Helpers.job_path(conn, :index))
    |> halt()
  end


end

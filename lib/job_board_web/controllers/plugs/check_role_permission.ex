defmodule JobBoardWeb.Plugs.CheckRolePermission do
  import JobBoardWeb.Plugs.PermissionHelper

  alias JobBoard.Repo

  def init(_params) do
  end

  def call(conn, _params) do
    user = conn.assigns.current_user
    |> Repo.preload(:role)

    if user.role.admin do
      conn
    else
      unauthorized(conn)
    end
  end
end

defmodule JobBoardWeb.Plugs.APIRequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias JobBoard.Repo

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:current_user] do
      user = conn.assigns[:current_user]
      |> Repo.preload(:role)
      if user.role.post_free do
        conn
      else
        conn
        |> put_status(:unauthorized)
        |> put_view(JobBoardWeb.ErrorView)
        |> render("401.json", message: "Unauthorized user")
        |> halt()
      end
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(JobBoardWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end
end

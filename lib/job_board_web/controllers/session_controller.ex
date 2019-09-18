defmodule JobBoardWeb.SessionController do
  use JobBoardWeb, :controller
  alias JobBoardWeb.AuthController

  def new(conn, _) do
    render(conn, "new.html", pagetitle: "Login", secure: true)
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case AuthController.login_by_email_and_pass(conn, email, pass) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.job_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html", pagetitle: "Login", secure: true)
    end
  end

  def delete(conn, _) do
    conn
    |> AuthController.logout()
    |> redirect(to: Routes.job_path(conn, :index))
  end
end

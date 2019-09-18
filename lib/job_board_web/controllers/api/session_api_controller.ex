defmodule JobBoardWeb.SessionAPIController do
  use JobBoardWeb, :controller

  alias JobBoard.Accounts

  def sign_in(conn, %{"user" => %{"email" => email, "password" => pass}}) do
    case Accounts.authenticate_by_email_and_pass(email, pass) do
      {:ok, user} ->
        conn
        |> JobBoardWeb.AuthController.login(user)
        |> put_status(:ok)
        |> put_view(JobBoardWeb.SessionView)
        |> render("sign_in.json", user: user)

      {:error, _reason} ->
        conn
        |> clear_session()
        |> put_status(:unauthorized)
        |> put_view(JobBoardWeb.ErrorView)
        |> render("401.json", message: "Wrong email/password")
    end
  end

  def csrf_token(conn, _) do
    conn
        |> put_resp_cookie("__csrf", Plug.CSRFProtection.get_csrf_token())
        |> put_view(JobBoardWeb.SessionView)
        |> render("csrftoken.json")
  end
end

defmodule JobBoardWeb.AuthController do
  use JobBoardWeb, :controller

  alias JobBoard.Accounts



  def logout(conn) do
    Accounts.remove_token(conn.assigns.current_user)
    conn
    |> clear_session()
    |> put_flash(:info, "Signed Out")
  end

  def login(conn, user) do
    token = Accounts.set_token(user)
    conn
    |> put_session(:token, token)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end
end

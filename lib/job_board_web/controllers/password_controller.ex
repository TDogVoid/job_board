defmodule JobBoardWeb.PasswordController do
  use JobBoardWeb, :controller

  alias JobBoard.Accounts
  alias JobBoard.Accounts.User
  alias JobBoard.Repo

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", pagetitle: "Forgot Password", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.get_user_by_email(user_params["credential"]["email"]) do
      %User{} = user ->
        reset_token = JobBoard.Token.generate_new_account_token(user)
        reset_url = Routes.password_url(conn, :reset, token: reset_token)

        user = user
        |> Repo.preload(:credential)

        JobBoard.Email.reset_password(user.credential.email, reset_url)
        |> JobBoard.Mailer.deliver_later
      _ ->
        ""
    end

    # send this message regardless so it isn't known for hackers to test various emails
    conn
    |> put_flash(:info, "Reset token sent to user")
    |> redirect(to: Routes.job_path(conn, :index))
  end

  def reset(conn, %{"token" => token}) do
    with {:ok, user_id} <- JobBoard.Token.verify_password_reset_token(token),
      user <- Accounts.get_user!(user_id) do
        conn
        |> JobBoardWeb.AuthController.login(user)
        |> redirect(to: Routes.user_path(conn, :edit, user))
    else
      _ ->
        conn
      |> put_flash(:info, "Invalid Token")
      |> redirect(to: Routes.job_path(conn, :index))
    end
  end
end

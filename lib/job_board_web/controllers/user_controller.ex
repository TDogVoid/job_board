defmodule JobBoardWeb.UserController do
  use JobBoardWeb, :controller

  alias JobBoard.Accounts
  alias JobBoard.Accounts.User
  alias JobBoard.Repo
  alias JobBoard.Jobs

  plug JobBoardWeb.Plugs.RequireAuth when action in [:index, :show, :edit, :update, :delete]
  plug JobBoardWeb.Plugs.CheckUserPermission when action in [:index, :show, :edit, :update, :delete]
  plug :secure_tag

  def index(conn, _params) do
    # conn = check_permission_to_view_index(conn)
    users = Accounts.list_users()
    |> Repo.preload(:credential)
    render(conn, "index.html", users: users, pagetitle: "List of Users")
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset, pagetitle: "New User")
  end

  def create(conn, params) do
    %{"user" => user_params} = params
    case Recaptcha.verify(params["g-recaptcha-response"]) do
      {:ok, _} -> register_user(conn, user_params)
      {:error, errors} -> failed_recaptcha(conn, user_params, errors)
    end
  end

  defp failed_recaptcha(conn, user_params, _) do
    changeset = User.changeset(%User{}, user_params)
    conn
    |> put_flash(:error, "Failed Recaptcha")
    |> render("new.html", changeset: changeset, pagetitle: "New User")
  end

  defp register_user(conn, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        email_verification(conn, user)

        if user_params["newsletter"] == "true" do
          JobBoard.Newsletter.add_member(user)
        end

        JobBoard.NotifyMe.new_user(user)
        |> JobBoard.Mailer.deliver_later

        conn
        |> JobBoardWeb.AuthController.login(user)
        |> put_flash(:info, "User Succesfully Created")
        |> redirect(to: Routes.job_path(conn, :index))


      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, pagetitle: "New User")
    end
  end

  def show(conn, %{"id" => id} = params) do
    page = params["page"] || 1

    conn_user = conn.assigns.current_user
    |> Repo.preload(:role)

    user = Accounts.get_user!(id)
    |> Repo.preload(:credential)
    |> Repo.preload(:role)

    jobs = Jobs.page_of_jobs(id, page)

    jobs_list = jobs.list
    |> Repo.preload(:user)
    |> Repo.preload(:city)
    |> Repo.preload(city: :state)

    jobs = jobs = %{jobs | list: jobs_list}

    if conn_user.role.admin do
      changeset = Accounts.change_user(user)
      roles = Accounts.list_roles()

      render(conn, "show.html", user: user, changeset: changeset, roles: roles, jobs: jobs, pagetitle: "Profile")
    else
      render(conn, "show.html", user: user, jobs: jobs, pagetitle: "Profile")
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    |> Repo.preload(:credential)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset, pagetitle: "Edit User")
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user  = Accounts.get_user!(id)
    |> Repo.preload(:credential)

    current_user = conn.assigns.current_user
    |> Repo.preload(:role)

    if current_user.role.admin do
      process_update_when_admin(conn, user, Accounts.update_user_direct_params(user, user_params))
    else
      process_update(conn, user, Accounts.update_user(user, user_params))
    end
  end

  defp process_update(conn, user, update) do
    case update do
      {:ok, user} ->
        conn
        |> JobBoardWeb.AuthController.login(user)
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, pagetitle: "Edit User")
    end
  end

  defp process_update_when_admin(conn, user, update) do
    case update do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, pagetitle: "Edit User")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.job_path(conn, :index))
  end

  def verify_email(conn, %{"token" => token}) do
    with {:ok, user_id} <- JobBoard.Token.verify_new_account_token(token),
          %User{verified: false} = user <- Accounts.get_user!(user_id) do
            Accounts.mark_as_verified(user)

            conn
            |> put_flash(:info, "Email Verified")
            |> redirect(to: Routes.user_path(conn, :show, user))
    else
      _ ->
        conn
      |> put_flash(:info, "Invalid Token")
      |> redirect(to: Routes.job_path(conn, :index))
    end
  end

  def verify_email(conn, _) do
    conn
    |> put_flash(:info, "The verification link is invalid")
    |> redirect(to: Routes.job_path(conn, :index))
  end

  defp email_verification(conn, user) do
    email_token = JobBoard.Token.generate_new_account_token(user)
    verification_url = Routes.user_url(conn, :verify_email, token: email_token)

    user = user
    |> Repo.preload(:credential)

    JobBoard.Email.verify_email(user.credential.email, verification_url)
    |> JobBoard.Mailer.deliver_later
  end

  def resend_verification(conn, _) do
    user = conn.assigns.current_user
    if !user.verified do
      email_verification(conn, user)

      conn
      |> put_flash(:info, "Email verification sent")
      |> redirect(to: Routes.user_path(conn, :show, user))
    else
      conn
      |> put_flash(:info, "Email already verified")  # shouldn't ever get here but just in case
      |> redirect(to: Routes.user_path(conn, :show, user))
    end
  end

  defp secure_tag(conn, _) do
    Plug.Conn.assign(conn, :secure, true)
  end
end

defmodule JobBoardWeb.RoleController do
  use JobBoardWeb, :controller

  alias JobBoard.Accounts
  alias JobBoard.Accounts.Role
  alias JobBoard.Repo

  plug JobBoardWeb.Plugs.RequireAuth
  plug JobBoardWeb.Plugs.CheckRolePermission

  def index(conn, _params) do
    roles = Accounts.list_roles()
    |> Repo.preload(:user)
    render(conn, "index.html", roles: roles, pagetitle: "List of Roles")
  end

  def new(conn, _params) do
    changeset = Accounts.change_role(%Role{})
    render(conn, "new.html", changeset: changeset, pagetitle: "New Role")
  end

  def create(conn, %{"role" => role_params}) do
    case Accounts.create_role(role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, pagetitle: "New Role")
    end
  end

  def show(conn, %{"id" => id}) do
    role = Accounts.get_role!(id)
    |> Repo.preload(:user)
    render(conn, "show.html", role: role, pagetitle: role.name)
  end

  def edit(conn, %{"id" => id}) do
    role = Accounts.get_role!(id)
    changeset = Accounts.change_role(role)
    render(conn, "edit.html", role: role, changeset: changeset, pagetitle: "Edit Role")
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Accounts.get_role!(id)

    case Accounts.update_role(role, role_params) do
      {:ok, role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: Routes.role_path(conn, :show, role))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", role: role, changeset: changeset, pagetitle: "Edit Role")
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Accounts.get_role!(id)
    {:ok, _role} = Accounts.delete_role(role)

    conn
    |> put_flash(:info, "Role deleted successfully.")
    |> redirect(to: Routes.role_path(conn, :index))
  end
end

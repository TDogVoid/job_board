defmodule JobBoardWeb.StateController do
  use JobBoardWeb, :controller

  alias JobBoard.States
  alias JobBoard.States.State

  plug JobBoardWeb.Plugs.RequireAuth
  plug JobBoardWeb.Plugs.RequireAdmin

  def index(conn, _params) do
    states = States.list_states()
    render(conn, "index.html", states: states, pagetitle: "List of States")
  end

  def new(conn, _params) do
    changeset = States.change_state(%State{})
    render(conn, "new.html", changeset: changeset, pagetitle: "New State")
  end

  def create(conn, %{"state" => state_params}) do
    case States.create_state(state_params) do
      {:ok, state} ->
        conn
        |> put_flash(:info, "State created successfully.")
        |> redirect(to: Routes.state_path(conn, :show, state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, pagetitle: "New State")
    end
  end

  def show(conn, %{"id" => id}) do
    state = States.get_state!(id)
    render(conn, "show.html", state: state, pagetitle: state.name)
  end

  def edit(conn, %{"id" => id}) do
    state = States.get_state!(id)
    changeset = States.change_state(state)
    render(conn, "edit.html", state: state, changeset: changeset, pagetitle: "Edit State")
  end

  def update(conn, %{"id" => id, "state" => state_params}) do
    state = States.get_state!(id)

    case States.update_state(state, state_params) do
      {:ok, state} ->
        conn
        |> put_flash(:info, "State updated successfully.")
        |> redirect(to: Routes.state_path(conn, :show, state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", state: state, changeset: changeset, pagetitle: "Edit State")
    end
  end

  def delete(conn, %{"id" => id}) do
    state = States.get_state!(id)
    {:ok, _state} = States.delete_state(state)

    conn
    |> put_flash(:info, "State deleted successfully.")
    |> redirect(to: Routes.state_path(conn, :index))
  end
end

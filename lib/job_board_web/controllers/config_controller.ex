defmodule JobBoardWeb.ConfigController do
  use JobBoardWeb, :controller

  alias JobBoard.Siteconfigs

  plug JobBoardWeb.Plugs.RequireAuth
  plug JobBoardWeb.Plugs.RequireAdmin


  def index(conn, _params) do
    configs = Siteconfigs.list_configs()
    render(conn, "index.html", configs: configs, pagetitle: "Config Index")
  end

  def show(conn, %{"id" => id}) do
    config = Siteconfigs.get_config!(id)
    render(conn, "show.html", config: config, pagetitle: "Site Config")
  end

  def edit(conn, %{"id" => id}) do
    config = Siteconfigs.get_config!(id)
    changeset = Siteconfigs.change_config(config)
    render(conn, "edit.html", config: config, changeset: changeset, pagetitle: "Edit Config")
  end

  def update(conn, %{"id" => id, "config" => config_params}) do
    config = Siteconfigs.get_config!(id)

    Cachex.reset(:config)

    case Siteconfigs.update_config(config, config_params) do
      {:ok, config} ->
        conn
        |> put_flash(:info, "Config updated successfully.")
        |> redirect(to: Routes.config_path(conn, :show, config))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", config: config, changeset: changeset, pagetitle: "Edit Config")
    end
  end
end

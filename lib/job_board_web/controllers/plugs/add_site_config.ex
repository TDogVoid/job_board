defmodule JobBoardWeb.Plugs.AddSiteConfig do
  import Plug.Conn
  alias JobBoard.Siteconfigs

  def init(_params) do
  end

  def call(conn, _params) do
    conn
    |> assign(:config, Siteconfigs.get_main)
  end
end

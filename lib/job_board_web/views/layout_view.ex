defmodule JobBoardWeb.LayoutView do
  use JobBoardWeb, :view
  alias Number.Currency
  alias JobBoardWeb.Router.Helpers, as: Routes

  def get_version() do
    {:ok, vsn} = :application.get_key(:job_board, :vsn)
    List.to_string(vsn)
  end

  def get_post_price(conn) do
    conn.assigns.config.post_price / 100
    |> Currency.number_to_currency
  end

  def get_post_link_text(conn) do
    "Post a Job for #{get_post_price(conn)}"
  end

  def get_site_name(conn) do
    conn.assigns.config.site_name
  end

  def get_site_slug(conn) do
    conn.assigns.config.site_slug
  end

  def get_current_url(conn) do
    Routes.url(conn)
  end
end

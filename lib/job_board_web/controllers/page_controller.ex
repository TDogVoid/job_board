defmodule JobBoardWeb.PageController do
  use JobBoardWeb, :controller

  def contact(conn, _params) do
    render conn, "contact.html", pagetitle: "Contact"
  end

  def about(conn, _params) do
    render conn, "about.html", pagetitle: "About"
  end

  def construction(conn, _params) do
    render conn, "construction.html", pagetitle: "Construction"
  end

  def privacy(conn, _params) do
    render conn, "privacy.html", pagetitle: "Privacy Page"
  end

  def terms(conn, _params) do
    render conn, "terms.html", pagetitle: "Terms and Conditions of Use"
  end
end

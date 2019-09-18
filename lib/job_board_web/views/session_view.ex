defmodule JobBoardWeb.SessionView do
  use JobBoardWeb, :view

  def render("sign_in.json", %{user: user}) do
    %{user: %{id: user.id}}
  end

  def render("csrftoken.json", _) do
    %{}
  end
end

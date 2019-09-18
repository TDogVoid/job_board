defmodule JobBoardWeb.Plugs.SetUser do
  import Plug.Conn
  alias JobBoard.Repo
  alias JobBoard.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    token = get_session(conn, :token)

    cond do
      user = user_id && token && Accounts.get_user(user_id) ->
        user = Repo.preload(user, :role)
        if Accounts.check_token(user, token) do
          assign(conn, :current_user, user)
        else
          assign(conn, :current_user, nil)
        end
      true ->
        assign(conn, :current_user, nil)
    end
  end
end

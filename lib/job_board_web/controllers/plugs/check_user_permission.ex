defmodule JobBoardWeb.Plugs.CheckUserPermission do
  import JobBoardWeb.Plugs.PermissionHelper

  alias JobBoard.Repo

  def init(_params) do
  end

  def call(conn, _params) do
    user = conn.assigns.current_user
    |> Repo.preload(:role)

    role = user.role
    if role do
      case conn.private.phoenix_action do
        :index ->
          if role.can_edit_other_users || role.admin do
            conn
          else
            unauthorized(conn)
          end
        :show ->
          if check_user_owner(conn) || role.can_view_other_users || role.admin do
            conn
          else
            unauthorized(conn)
          end
        :edit ->
          if check_user_owner(conn) || (role.can_edit_other_users && !is_account_being_edited_admin(conn)) || role.admin do
            conn
          else
            unauthorized(conn)
          end
        :update ->
          if check_user_owner(conn) || (role.can_edit_other_users && !is_account_being_edited_admin(conn)) || role.admin do
            conn
          else
            unauthorized(conn)
          end
        :delete ->
          if check_user_owner(conn) || (role.can_delete_other_users && !is_account_being_edited_admin(conn)) || role.admin do
            conn
          else
            unauthorized(conn)
          end
        _ ->
          unauthorized(conn)
      end
    else
      unauthorized(conn)
    end
  end

  defp check_user_owner(%{params: %{"id" => user_id}} = conn) do
    conn.assigns.current_user && String.to_integer(user_id) == conn.assigns.current_user.id
  end

  defp is_account_being_edited_admin(conn) do
    %{"id" => id} = conn.params
    user = JobBoard.Accounts.get_user(id)
    |> Repo.preload(:role)
    user.role.admin
  end
end



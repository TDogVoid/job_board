defmodule JobBoardWeb.JobView do
  use JobBoardWeb, :view

  def company(job) do
    job.company || job.user.company
  end

  def time_from_now(time)do
    {:ok, t} = Timex.format(time, "{relative}", :relative)
    t
  end

  def render("job.json", %{message: message, job: _job}) do
    %{status: message}
  end

  def can_view_edit_buttons(conn, job) do
    conn.assigns.current_user && conn.assigns.current_user.id == job.user_id || conn.assigns.current_user && conn.assigns.current_user.role.admin
  end

  def is_admin(conn) do
    conn.assigns.current_user && conn.assigns.current_user.role.admin
  end

  def get_post_price(conn) do
    JobBoardWeb.LayoutView.get_post_price(conn)
  end

  def can_post_free(conn) do
    conn.assigns.current_user.role.post_free || conn.assigns.current_user.role.admin
  end

  def stripe_key() do
    Application.fetch_env!(:stripy, :public_key)
  end

  def get_site_slug(conn) do
    conn.assigns.config.site_slug
  end
end

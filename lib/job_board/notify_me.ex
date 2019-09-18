defmodule JobBoard.NotifyMe do
  import Bamboo.Email
  @email "Ohio Nurse Jobs <support@ohionursejobs.com>"
  alias JobBoardWeb.Router.Helpers, as: Routes


  def new_user(user) do
    url = Routes.user_url(JobBoardWeb.Endpoint, :show, user)
    new_email()
    |> to(@email)
    |> from(@email)
    |> subject("I got a new user")
    |> html_body("I got a new user <a href='#{url}'>#{url}</a>")
    |> text_body("I got a new user #{url}")
  end

  def new_purchase(job) do
    url = Routes.job_url(JobBoardWeb.Endpoint, :show, job)
    new_email()
    |> to(@email)
    |> from(@email)
    |> subject("Someone posted a job")
    |> html_body("Someone posted <a href='#{url}'>#{url}</a>" )
    |> text_body("Someone posted #{url}")
  end

end

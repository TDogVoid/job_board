defmodule JobBoard.Email do
  import Bamboo.Email
  @email "Ohio Nurse Jobs <support@ohionursejobs.com>"

  def verify_email(user_email, validation_url) do
    new_email()
    |> to(user_email)
    |> from(@email)
    |> subject("Welcome! Please verify your email address")
    |> html_body("Welcome! Please verify your email by going to <a href='#{validation_url}'>#{validation_url}</a>")
    |> text_body("Welcome! Please verify your email by going to #{validation_url}")
  end

  def reset_password(user_email, url) do
    new_email()
    |> to(user_email)
    |> from(@email)
    |> subject("Reset password")
    |> html_body("Click link to reset your password <a href='#{url}'>#{url}</a> <br> Token only valid for 5 mins")
    |> text_body("Click link to reset your password #{url}
    Token only valid for 5 mins")
  end
end

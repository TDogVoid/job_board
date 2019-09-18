defmodule JobBoard.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """

  alias JobBoard.Accounts.User
  @account_verification_salt System.get_env("SECRET_ACCOUNT_VERIFICATION_SALT") || "temp"

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(JobBoardWeb.Endpoint, @account_verification_salt, user_id)
  end

  def verify_new_account_token(token) do
    max_age = 86_400 # tokens that are older than a day should be invalid
    Phoenix.Token.verify(JobBoardWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end

  def verify_password_reset_token(token) do
    max_age = 300 # tokens that are older than a 5 mins should be invalid
    Phoenix.Token.verify(JobBoardWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end
end

defmodule JobBoard.Stripe do
  alias JobBoard.Accounts
  alias JobBoard.Accounts.User
  alias JobBoard.Repo

  def email(user) do
    {:ok, res} = Stripy.req(:get, "customers/#{user.stripe_id}")
    res["email"]
  end

  def charge(:customer, amount, customer_id) do
    charge = %{"amount" => amount, "currency" => "usd", "description" => "Charge for Ohio Nurse Jobs Post", "customer" => customer_id}
    Stripy.parse(Stripy.req(:post, "charges", charge)) # {:ok, res}
  end

  def charge(:token, amount, token) do
    charge = %{"amount" => amount, "currency" => "usd", "description" => "Charge for Ohio Nurse Jobs Post", "source" => token}
    Stripy.parse(Stripy.req(:post, "charges", charge)) # {:ok, res}
  end

  def charge(:token, amount, token, email) do
     # this sends email regardless of stripes settings
    charge = %{"amount" => amount, "currency" => "usd", "description" => "Charge for Ohio Nurse Jobs Post", "source" => token, "receipt_email" => email}
    Stripy.parse(Stripy.req(:post, "charges", charge)) # {:ok, res}
  end

  def create_customer(email) do
    data = %{"email" => email}
    {:ok, res} = Stripy.parse(Stripy.req(:post, "customers", data))
    res["id"]
  end

  def insert_or_get_customer_stripe_id(%User{} = user) do
    if user.stripe_id != nil do
      user.stripe_id
    else
      user = user
      |> Repo.preload(:credential)
      id = create_customer(user.credential.email)
      Accounts.set_stripe_id(user, id)
      id
    end
  end

  def create_card(token, user) do
    data = %{"source" => token}
    {:ok, res} = Stripy.parse(Stripy.req(:post, "customers/#{user.stripe_id}/sources", data))
    res["id"]
  end

  def set_customer_default_card(source, user) do
    data = %{"default_source" => source}
    Stripy.parse(Stripy.req(:post, "customers/#{user.stripe_id}", data)) # return {:ok, res}
  end
end

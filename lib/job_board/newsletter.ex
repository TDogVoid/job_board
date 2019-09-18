defmodule JobBoard.Newsletter do
  alias Mailchimp.List


  def get_list() do
    Mailchimp.Account.get!
    |> Mailchimp.Account.lists!
    |> Enum.find(fn l -> l.id == "640b10d79f" end)
  end

  def add_member(user) do
    Task.async(fn -> add_member_async(user) end)
  end

  defp add_member_async(user) do
    List.create_member(get_list(), user.credential.email, :subscribed, %{FNAME: user.name}, %{})
  end
end

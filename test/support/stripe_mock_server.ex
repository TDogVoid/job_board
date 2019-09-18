defmodule JobBoard.StripeMockServer do
  @behaviour Stripy.MockServer

  @ok_res %{status_code: 200}

  @impl Stripy.MockServer

  def request(:post, "charges", %{}) do
    body = Poison.encode!(%{"status" => "succeeded"})
    {:ok, Map.put(@ok_res, :body, body)}
  end


end

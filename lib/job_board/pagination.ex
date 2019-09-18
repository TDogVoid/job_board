defmodule JobBoard.Pagination do
  import Ecto.Query
  alias JobBoard.Repo

  def query(query, page, per_page: per_page) when is_binary(page) do
    query(query, String.to_integer(page), per_page: per_page)
  end

  def query(query, page, per_page: per_page) do
    query
    |> limit(^(per_page + 1))
    |> offset(^(per_page * (page - 1)))
    |> Repo.all()
  end

  def page(query, page, per_page: per_page) when is_binary(page) do
    page(query, String.to_integer(page), per_page: per_page)
  end

  def page(query, page, per_page: per_page) do
    page(query, page, per_page: per_page, error: nil)
  end

  def page(query, page, per_page: per_page, error: error) do
    results = query(query, page, per_page: per_page)
    has_next = length(results) > per_page
    has_prev = page > 1
    count = count(query)

    %{
      error: error,
      has_next: has_next,
      has_prev: has_prev,
      prev_page: page - 1,
      page: page,
      next_page: page + 1,
      first: (page - 1) * per_page + 1,
      last: Enum.min([page * per_page, count]),
      count: count,
      list: Enum.slice(results, 0, per_page)
    }
  end

  defp count(query) do
    query
    |> exclude(:preload)
    |> subquery
    |> select(count("*"))
    |> Repo.one()
  end
end
defmodule JobBoardWeb.JobControllerTest do
  use JobBoardWeb.ConnCase

  alias JobBoard.Jobs
  alias JobBoard.Repo

  import JobBoard.TestHelpers

  @create_attrs %{title: "some title", link: "http://SomeLink.com", stripeToken: "111111"}
  @update_attrs %{title: "some updated title", link: "http://updatedlink.com"}
  @invalid_attrs %{title: nil, description: nil, link: nil}
  @missing_title_attrs %{title: nil, link: "http://SomeLink.com"}
  @missing_link_attrs %{title: "some updated title", description: "updated description", link: nil}


  setup do
    Cachex.reset(:jobs)
    setup_config()
  end

  def fixture(:job) do
    {:ok, job} = Jobs.create_job(@create_attrs)
    job
  end

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "Job List"
    end
  end

  describe "new job" do
    test "renders form", %{conn: conn} do
      conn = signin(conn)
      conn = get conn, job_path(conn, :new)

      assert html_response(conn, 200) =~ "Job Post"
    end

    test "renders error if not logged in", %{conn: conn} do
      conn = get conn, job_path(conn, :new)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in."
    end

    test "redirects unverified user", %{conn: conn} do
      {conn, user} = sigin_unverified_conn_and_user(conn)

      conn = get conn, job_path(conn, :new)
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "verify email"
    end
  end

  describe "create job" do
    setup [:create_city]

    test "redirects to show when data is valid", %{conn: conn, city: city} do
      conn = signin(conn)
      attrs = Map.put(@create_attrs, :zipcode, city.zipcode)
      conn = post conn, job_path(conn, :create), job: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == job_path(conn, :show, id)

      conn = get conn, job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Job created successfully"
    end

    test "renders errors when data is invalid", %{conn: conn, city: city} do
      conn = signin(conn)
      attrs = Map.put(@invalid_attrs, :zipcode, city.zipcode)
      conn = post conn, job_path(conn, :create), job: attrs
      assert html_response(conn, 200) =~ "Job Post"
    end

    test "renders errors missing title", %{conn: conn, city: city} do
      conn = signin(conn)
      attrs = Map.put(@missing_title_attrs, :zipcode, city.zipcode)
      conn = post conn, job_path(conn, :create), job: attrs
      assert html_response(conn, 200) =~ "Job Post"
    end

    test "renders errors missing link", %{conn: conn, city: city} do
      conn = signin(conn)
      attrs = Map.put(@missing_link_attrs, :zipcode, city.zipcode)
      conn = post conn, job_path(conn, :create), job: attrs
      assert html_response(conn, 200) =~ "Job Post"
    end

    test "without user", %{conn: conn, city: city} do
      attrs = Map.put(@create_attrs, :zipcode, city.zipcode)
      conn = post conn, job_path(conn, :create), job: attrs
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in."
    end

    test "redirects unverified user", %{conn: conn, city: city} do
      {conn, user} = sigin_unverified_conn_and_user(conn)
      attrs = Map.put(@missing_link_attrs, :zipcode, city.zipcode)

      conn = post conn, job_path(conn, :create), job: attrs
      assert redirected_to(conn) == user_path(conn, :show, user)

      conn = get conn, user_path(conn, :show, user)
      assert html_response(conn, 200) =~ "verify email"
    end
  end

  describe "edit job" do
    setup [:create_job]

    test "renders form for editing chosen job", %{conn: conn, job: job} do
      conn = signin(conn)
      conn = get conn, job_path(conn, :edit, job)
      assert html_response(conn, 200) =~ "Edit Job"
    end

    test "renders form for editing chosen job when admin", %{conn: conn, job: job} do
      conn = signin_admin(conn)
      conn = get conn, job_path(conn, :edit, job)
      assert html_response(conn, 200) =~ "Edit Job"
    end

    test "renders error must be logged", %{conn: conn, job: job} do
      conn = get conn, job_path(conn, :edit, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in."
    end

    test "renders error attempting to edit someonelse job", %{conn: conn, job: job} do
      conn = signin_other(conn)

      conn = get conn, job_path(conn, :edit, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You cannot edit that"
    end
  end

  describe "update job" do
    setup [:create_job]

    test "redirects when data is valid", %{conn: conn, job: job} do
      conn = signin(conn)
      job = job
      |> Repo.preload(:city)

      attrs = @update_attrs
      |> Map.put(:zipcode, job.city.zipcode)
      conn = put conn, job_path(conn, :update, job), job: attrs
      assert redirected_to(conn) == job_path(conn, :show, job)

      conn = get conn, job_path(conn, :show, job)
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, job: job} do
      conn = signin(conn)

      job = job
      |> Repo.preload(:city)

      attrs = @invalid_attrs
      |> Map.put(:zipcode, job.city.zipcode)

      conn = put conn, job_path(conn, :update, job), job: attrs
      assert html_response(conn, 200) =~ "Edit Job"
    end

    test "renders errors when missing title", %{conn: conn, job: job} do
      conn = signin(conn)

      job = job
      |> Repo.preload(:city)

      attrs = @missing_title_attrs
      |> Map.put(:zipcode, job.city.zipcode)

      conn = put conn, job_path(conn, :update, job), job: attrs
      assert html_response(conn, 200) =~ "Edit Job"
    end

    test "renders errors when missing link", %{conn: conn, job: job} do
      conn = signin(conn)

      job = job
      |> Repo.preload(:city)

      attrs = @missing_link_attrs
      |> Map.put(:zipcode, job.city.zipcode)

      conn = put conn, job_path(conn, :update, job), job: attrs
      assert html_response(conn, 200) =~ "Edit Job"
    end

    test "renders must be logged in", %{conn: conn, job: job} do

      job = job
      |> Repo.preload(:city)

      attrs = @update_attrs
      |> Map.put(:zipcode, job.city.zipcode)

      conn = put conn, job_path(conn, :update, job), job: attrs

      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in"
    end

    test "renders error attempting to update someonelse job", %{conn: conn, job: job} do
      conn = signin_other(conn)

      conn = put conn, job_path(conn, :update, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You cannot edit that"
    end

    test "renders error must be logged", %{conn: conn, job: job} do
      conn = put conn, job_path(conn, :update, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in."
    end

  end

  describe "delete job" do
    setup [:create_job]

    test "deletes chosen job", %{conn: conn, job: job} do
      conn = signin(conn)
      conn = delete conn, job_path(conn, :delete, job)
      assert redirected_to(conn) == job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, job_path(conn, :show, job)
      end
    end


    test "renders error must be logged in", %{conn: conn, job: job} do
      conn = delete conn, job_path(conn, :delete, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You must be logged in."
    end

    test "renders error attempting to delete someonelse job", %{conn: conn, job: job} do
      conn = signin_other(conn)

      conn = delete conn, job_path(conn, :delete, job)
      assert redirected_to(conn) == job_path(conn, :index)

      conn = get conn, job_path(conn, :index)
      assert html_response(conn, 200) =~ "You cannot edit that"
    end

  end

  describe "show" do
    setup [:create_job]

    test "renders job if not logged in",  %{conn: conn, job: job} do
      conn = get conn, job_path(conn, :show, job)
      assert html_response(conn, 200) =~ "some title"
    end
  end

  defp create_job(_) do
    create_users()
    conn = build_conn()
    conn = signin(conn)

    city = city_fixture(:city)
    attrs = Map.put(@create_attrs, :zipcode, city.zipcode)

    conn = post conn, job_path(conn, :create), job: attrs
    %{id: id} = redirected_params(conn)
    job = Jobs.get_job!(id)
    {:ok, job: job}
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Job List"
  end
end

defmodule JobBoard.JobsTest do
  use JobBoard.DataCase

  alias JobBoard.Jobs

  import JobBoard.TestHelpers

  describe "jobs" do
    alias JobBoard.Jobs.Job
    import JobBoard.TestHelpers

    @valid_attrs %{title: "some title", link: "http://somelink.com"}
    @update_attrs %{title: "some updated title", link: "http://updatedlink.com"}
    @invalid_attrs %{title: nil, link: nil}
    @missing_title_attrs %{title: nil, link: "http://somelink.com"}
    @missing_link_attrs %{title: "some updated title", description: "updated description", link: nil}
    @invalid_link_attrs %{title: "some updated title", description: "updated description", link: "somelink.com"}

    def job_fixture(attrs \\ %{}) do
      city = city_fixture(:city)
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:zipcode, city.zipcode)
        |> Jobs.create_job()
      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      |> Map.put(:zipcode, nil) # virtual field
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      |> Map.put(:zipcode, nil) # virtual field
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      city = city_fixture(:city)
      attrs = Map.put(@valid_attrs, :zipcode, city.zipcode)
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.title == "some title"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "create_job/1 with missing title returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@missing_title_attrs)
    end

    test "create_job/1 with missing link returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@missing_link_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Jobs.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.title == "some updated title"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      job = Map.put(job, :zipcode, nil) # virtual field
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end

    test "body includes no stripped tags" do
      changeset = Job.changeset(%Job{}, @valid_attrs)
      assert get_change(changeset, :description) == @valid_attrs[:description]
    end

    test "invalid link, missing http" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_link_attrs)
    end
  end
end

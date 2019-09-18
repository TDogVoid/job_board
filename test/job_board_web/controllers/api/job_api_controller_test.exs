defmodule JobBoardWeb.JobAPIControllerTest do
  use JobBoardWeb.ConnCase

  import JobBoard.TestHelpers

  @create_attrs %{title: "some title", description: "Some description", link: "http://SomeLink.com"}
  @invalid_attrs %{title: "", description: "", link: ""}

  describe "create job" do
    setup [:create_city]
    test "test with valid data", %{conn: conn, city: city} do
      conn = signin_free(conn)
      attrs = Map.put(@create_attrs, :zipcode, city.zipcode)
      conn = post conn, job_api_path(conn, :create), job: attrs

      assert json_response(conn, 200) ==
        %{
          "status" => "Job Created",
        }
    end

    test "test with invalid data", %{conn: conn, city: city} do
      conn = signin_free(conn)
      attrs = Map.put(@invalid_attrs, :zipcode, city.zipcode)
      conn = post conn, job_api_path(conn, :create), job: attrs

      assert json_response(conn, 200)["errors"] != %{}
    end

    test "fail with unauthorized user", %{conn: conn, city: city} do
      conn = signin(conn)
      attrs = Map.put(@create_attrs, :zipcode, city.zipcode)
      conn = post conn, job_api_path(conn, :create), job: attrs

      assert json_response(conn, 401) ==
        %{
          "errors" =>
          %{"detail" => "Unauthorized user"}
        }
    end

    test "fail with unauthenticated user", %{conn: conn, city: city} do
      attrs = Map.put(@create_attrs, :zipcode, city.zipcode)
      conn = post conn, job_api_path(conn, :create), job: attrs

      assert json_response(conn, 401) ==
        %{
          "errors" =>
          %{"detail" => "Unauthenticated user"}
        }
    end
  end
end

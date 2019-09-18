defmodule JobBoard.TestHelpers do
  alias JobBoard.Accounts
  alias JobBoard.Siteconfigs

  import Plug.Test

  @user_attrs %{name: "some user", company: "some company", verified: true, credential: %{email: "some@user.com", password: "some password" }}
  @unverified_user %{name: "some unverified user", company: "some unverified company", verified: false, credential: %{email: "unverified@user.com", password: "some unverified password" }}
  @other_user %{name: "some other user", company: "other company", verified: true, credential: %{email: "some_other@user.com", password: "some other password" }}
  @admin_user %{name: "admin user", company: "admin company", verified: true, credential: %{email: "admin@user.com", password: "admin password" }}
  @create_role %{name: "some role", can_edit_others_job: false, can_delete_others_job: false, can_view_user_list: false, can_edit_other_users: false, can_delete_other_users: false, can_promote_users: false}


  @city_attrs %{name: "some name", zipcode: 42, state_id: nil, lat: 12, long: 42}
  def city_fixture(:city) do
    state = state_fixture(:state).id
    c = %{@city_attrs | state_id: state}
    {:ok, city} = JobBoard.Cities.create_city(c)
    city
  end

  def create_city(_) do
    city = city_fixture(:city)
    {:ok, city: city}
  end


  def create_state(_) do
    state = state_fixture(:state)
    {:ok, state: state}
  end

  @state_attrs %{name: "some name"}
  def state_fixture(:state) do
    {:ok, state} = JobBoard.States.create_state(@state_attrs)
    state
  end

  def create_user_role() do
    case Accounts.get_role_by(name: "User") do
      nil ->
        Accounts.create_role(%{name: "User"})
      role ->
        {:ok, role}
    end
  end

  def create_admin_role() do
    case Accounts.get_role_by(name: "Admin Role") do
      nil ->
        Accounts.create_role(%{name: "Admin Role", admin: true})
      role ->
        {:ok, role}
    end
  end

  def get_admin_role() do
    Accounts.get_role_by(admin: true)
  end

  def create_user(attrs \\ @user_attrs) do
    {:ok, role} = create_user_role()
    insert_or_get_user(attrs, role)
  end

  def create_admin(attrs) do
    {:ok, role} = create_admin_role()
    insert_or_get_user(attrs, role)
  end

  defp insert_or_get_user(attrs, role) do
    attrs = Map.put(attrs, :role_id, role.id)
    case Accounts.get_user_by_email(attrs.credential.email) do
      nil ->
        Accounts.register_user_direct_params(attrs)
      user ->
        {:ok, user}
    end
  end

  def create_users(_) do
    create_users()
  end

  def create_users() do
    create_user(@other_user)
    create_admin(@admin_user)
    {:ok, user} = create_user(@user_attrs)
    {:ok, user: user}
  end

  def signin(conn) do
    {:ok, user} = create_user(@user_attrs)
    conn
    |> test_session(user)
  end

  def signin_free(conn) do
    role = role_fixture(:role, %{name: "free", post_free: true})
    {:ok, user} = insert_or_get_user(@user_attrs, role)

    conn
    |> test_session(user)
  end

  def signin_other(conn) do
    {:ok, user} = create_user(@other_user)
    conn
    |> test_session(user)
  end

  def signin_admin(conn) do
    {:ok, user} = create_admin(@admin_user)
    conn
    |> test_session(user)
  end

  def sigin_unverified_conn_and_user(conn) do
    {:ok, user} = create_user(@unverified_user)
    conn = conn
    |> test_session(user)
    {conn, user}
  end

  defp test_session(conn, user) do
    token = Accounts.set_token(user)
    conn
    |> init_test_session(user_id: user.id)
    |> init_test_session(token: token)
  end

  def role_fixture(:role, attrs \\ @create_role) do
    {:ok, role} = Accounts.create_role(attrs)
    role
  end

  def admin_role_fixture(:role, attrs \\ @create_role) do
    {:ok, role} = Accounts.create_role(attrs)
    role
  end

  def setup_config() do
    fixture_config(:config)
    {:ok, state: :test}
  end
  @config_attrs %{post_price: 42, site_name: "some site_name", site_slug: "some site_slug", ucon: 0}
  def fixture_config(:config) do
    {:ok, config} = Siteconfigs.create_config(@config_attrs)
    config
  end
end

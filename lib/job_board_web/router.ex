defmodule JobBoardWeb.Router do
  use JobBoardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug JobBoard.CSPHeader
    plug JobBoardWeb.Plugs.AddSiteConfig
    plug JobBoardWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(:fetch_session)
    plug :protect_from_forgery
    plug JobBoardWeb.Plugs.SetUser
  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", JobBoardWeb do
    pipe_through :browser # Use the default browser stack

    get "/", JobController, :index
    resources "/jobs", JobController
    get "/jobs/:id/outbound", JobController, :outbound
    resources "/users", UserController, only: [:index, :new, :create, :show, :edit, :update, :delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/roles", RoleController
    resources "/states", StateController
    resources "/cities", CityController
    resources "/password", PasswordController
    resources "/siteconfigs", ConfigController
    get "/reset-password", PasswordController, :reset
    get "/contact", PageController, :contact
    get "/about", PageController, :about
    get "/privacy", PageController, :privacy
    get "/construction", PageController, :construction
    get "/terms", PageController, :terms
    get "/verify", UserController, :verify_email
    get "/reverify", UserController, :resend_verification


  end

  # Other scopes may use custom stacks.
  scope "/api", JobBoardWeb do
    pipe_through :api

    resources "/jobs", JobAPIController
    post("/sessions/sign_in", SessionAPIController, :sign_in)
    get("/sessions/csrftoken", SessionAPIController, :csrf_token)
    post("/jobs/create", JobAPIController, :create)
  end
end

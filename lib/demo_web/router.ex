defmodule DemoWeb.Router do
  use DemoWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {DemoWeb.LayoutView, :app}
  end

  pipeline :private do
    plug DemoWeb.Plugs.BasicAuth, username: "admin2", password: "secret3"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", PageController, :index

    post "/game", PageController, :game
    get "/robot", PageController, :robot
  end

  scope "/", DemoWeb do
    pipe_through [:browser, :private]

    get "/secret_admin",           SecretAdminController, :index
    post "/admin/remove_inactive", SecretAdminController, :remove_inactive
    post "/admin/force_restart",   SecretAdminController, :force_restart
  end

end

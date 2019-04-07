defmodule DemoWeb.SecretAdminController do
  use DemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def remove_inactive(conn, _params) do
    Demo.Store.remove_inactive()

    conn
    |> put_flash(:info, "Inactive users removed")
    |> redirect(to: "/secret_admin")
    |> halt()
  end

  def force_restart(conn, _params) do
    Demo.Store.force_restart()

    conn
    |> put_flash(:info, "Restarting the game server")
    |> redirect(to: "/secret_admin")
    |> halt()
  end
end

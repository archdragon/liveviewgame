defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"body" => body_param, "eyes" => eyes_param}) do
    uuid = Ecto.UUID.generate

    {eyes, _} = Integer.parse(eyes_param)
    {body, _} = Integer.parse(body_param)

    conn
    |> put_layout(:game)
    |> LiveView.Controller.live_render(DemoWeb.GameLive, session: %{character: %{eyes: eyes, body: body}, user_id: uuid})
  end
end

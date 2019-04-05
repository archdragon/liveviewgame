defmodule DemoWeb.RobotLive do
  use Phoenix.LiveView

  @field_size 300
  @character_size 40

  def render(assigns) do
    obstacles = Demo.ObstacleCourse.obstacles()

    ~L"""
    <div class="container">
      <div class="row">
        <div class="col-sm-6">
          <div class="spaceship">
            <div id="robot" style="transform: translate(<%=@state.robot.position_x %>px, <%=@state.robot.position_y %>px)">
              🤖
            </div>

            <%= for obstacle <- obstacles do %>
              <div class="obstacle obstacle-<%=obstacle.kind %>" style="width: <%=obstacle.size_x %>px; height: <%=obstacle.size_y %>px; transform: translate(<%=obstacle.x %>px, <%=obstacle.y %>px)">
              </div>

            <% end %>
          </div>
        </div>
      </div>

      <div class="row">
        <%=@state.robot.state %>
      </div>
    </div>
    """
  end

  def mount(_params, socket) do
    if connected?(socket) do
       :timer.send_interval(50, self(), :tick)
    end

    new_socket =
      socket
      |> load_data()

    {:ok, new_socket}
  end

  def handle_info(:tick, socket) do
    new_socket = load_data(socket)

    {:noreply, new_socket}
  end

  defp load_data(socket) do
    socket
    |> assign(%{state: Demo.Store.get_all()})
  end
end

defmodule DemoWeb.GameLive do
  use Phoenix.LiveView

  @field_size 300
  @character_size 40

  def render(assigns) do
    ~L"""
    <div class="container">
      <div class="row">
        <div class="col-sm-6">
          <div class="spaceship">
            <%= for player <- @state.players do %>
              <div id="<%=player.user_id %>" class="player character small" style="transform: translate(<%=player.position_x %>px, <%=player.position_y %>px)">
                <div class="eyes" style="background-image: url('/images/eyes_<%=player.character.eyes %>.png')"></div>
                <div class="body" style="background-image: url('/images/body_<%=player.character.body %>.png')"></div>
              </div>
            <% end %>
          </div>
        </div>
        <div class="col-sm-6">
          <div>
            <button phx-click="move_up">UP</button>
            <button phx-click="move_down">DOWN</button>
            <button phx-click="move_left">-</button>
            <button phx-click="move_right">+</button>
          </div>
          <%= @current_player.user_id %>
        </div>
      </div>
    </div>
    """
  end

  def mount(params = %{character: character, user_id: user_id}, socket) do
    player =
      params
      |> Map.put(:position_x, @field_size/2 - 15)
      |> Map.put(:position_y, @field_size/2 - 15)

    if connected?(socket) do
      :timer.send_interval(50, self(), :tick)

      new_socket =
        socket
        |> load_data()
        |> assign(current_player: player)

      {:ok, new_socket}
    else
      new_state = Demo.Store.register_player(player)

      new_socket =
        socket
        |> assign(%{state: new_state, current_player: player})

      {:ok, new_socket}
    end

    #
    # new_socket =
    #
    #
    #  socket
    # |> assign(%{
    #    characters: [],
    #    val: 0
    #  })


  end

  def handle_info(:tick, socket) do
    new_socket = load_data(socket)

    {:noreply, new_socket}
  end

  def handle_event("move_" <> direction, _, socket) do
    case direction do
      "left" ->  move(socket, -1, 0)
      "right" -> move(socket, 1, 0)
      "up" ->    move(socket, 0, -1)
      "down" ->  move(socket, 0, 1)
    end

    {:noreply, socket}
  end

  defp load_data(socket) do
    socket
    |> assign(%{state: Demo.Store.get_all()})
  end

  defp user_id(socket) do
    socket.assigns.current_player.user_id
  end

  defp move(socket, x, y) do
    socket
    |> user_id()
    |> Demo.Store.move(x, y)
  end
end

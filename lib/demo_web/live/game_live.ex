defmodule DemoWeb.GameLive do
  use Phoenix.LiveView

  @field_size 300
  @character_size 40

  def render(assigns) do
    ~L"""
    <div class="container">
      <div class="row">
        <div class="column">
          <div class="game-area-wrapper">
            <div class="spaceship" style="transform: <%=get_area_rotation(@state) %>">
              <div class="robot-control north">
                <span class="emojis">🤖⬆️</span>
              </div>
              <div class="robot-control south">
                <span class="emojis">🤖⬇️</span>
              </div>
              <div class="robot-control east">
                <span class="emojis">🤖⬅️</span>
              </div>
              <div class="robot-control west">
                <span class="emojis">🤖</span>
              </div>
              <%= for player <- @state.players do %>
                <div id="<%=player.user_id %>" class="player character small <%=player_class(player, @current_player.user_id) %>" style="transform: translate(<%=player.position_x %>px, <%=player.position_y %>px)">
                  <div class="eyes" style="background-image: url('/images/eyes_<%=player.character.eyes %>.png')"></div>
                  <div class="body" style="background-image: url('/images/body_<%=player.character.body %>.png')"></div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="controls">
      <button class="button-up" phx-click="move_up">UP</button>
      <button class="button-down" phx-click="move_down">DOWN</button>
      <button class="button-left" phx-click="move_left">-</button>
      <button class="button-right" phx-click="move_right">+</button>
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

  defp player_class(player, current_player_user_id) do
    case player.user_id == current_player_user_id do
      true -> "player-current"
      _ -> ""
    end
  end

  defp get_area_rotation(state) do
    multiplier = 20
    speed = state.robot.speed
    x = speed.x * multiplier
    y = speed.y * multiplier * -1
    "rotateX(#{y}deg) rotateY(#{x}deg)"
  end
end

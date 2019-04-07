defmodule Demo.Store do
  use GenServer

  @area_size 300
  @character_size 40
  @limit_y @area_size - @character_size
  @tick_interval 100
  @tick_cleanup_interval 2000
  @robot_init %{
    position_x: 0, # from 0 to 300
    position_y: 0, # from 0 to 300
    state: :neutral,
    speed: %{x: 0, y: 0}
  }
  @init_state %{
    players: [],
    robot: @robot_init,
    game: %{
      last_win: 0,
      last_loss: 0
    }
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def get_all() do
    GenServer.call(__MODULE__, {:get_all})
  end

  def register_player(player_data) do
    GenServer.call(__MODULE__, {:register_player, player_data})
  end

  def move(user_id, x, y) do
    GenServer.cast(__MODULE__, {:move, user_id, x, y})
  end

  def remove_inactive() do
    GenServer.cast(__MODULE__, :remove_inactive)
  end

  def force_restart() do
    GenServer.cast(__MODULE__, :force_restart)
  end

  def handle_call({:get_all}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:register_player, player_data}, _from, state) do
    player_data =
      player_data
      |> Map.put(:last_move_timestamp, timestamp())

    new_players = [player_data | state.players]

    new_state = %{state | players: new_players}

    {:reply, new_state, new_state}
  end

  def handle_cast({:move, user_id, x, y}, state) do
    x = x * (25 + :rand.uniform(5))
    y = y * (25 + :rand.uniform(5))

    new_players =
      state.players
      |> Enum.map(fn player ->
        case player.user_id == user_id do
          true ->
            new_x = clamp_position(player.position_x + x)
            new_y = clamp_position(player.position_y + y)

            %{player | position_x: new_x, position_y: new_y, last_move_timestamp: timestamp()}
          false ->
            player
        end
      end)

    new_state = %{state | players: new_players}

    {:noreply, new_state}
  end

  # TODO: Cast will be enough
  def handle_call({:replace_last, search_term}, _from, state) do
    new_item = %{text: search_term, timestamp: timestamp()}

    new_state =
      case state do
        [] -> [new_item]
        state -> List.replace_at(state, 0, new_item)
      end

    {:reply, :ok, new_state}
  end

  def handle_cast(:remove_inactive, state) do
    new_players =
      state.players
      |> Enum.reject(fn player ->
        player.last_move_timestamp + 60 < timestamp()
      end)

    new_state = %{state | players: new_players}

    {:noreply, new_state}
  end

  def handle_cast(:force_restart, state) do
    {:stop, :normal, state}
  end

  def init(_args) do
    tick()
    tick_cleanup()

    {:ok, @init_state}
  end

  def handle_info(:tick_cleanup, state) do
    remove_inactive()
    tick_cleanup()

    IO.puts("tick_cleanup")

    {:noreply, state}
  end

  def handle_info(:tick, state) do
    speed = state |> robot_recalculate_speed()
    obstacles = Demo.ObstacleCourse.obstacles()

    new_state =
      state
      |> robot_move(speed)
      |> robot_check_collisions(obstacles)
      |> robot_restart_if_needed()

    tick()

    {:noreply, new_state}
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  defp tick_cleanup, do: Process.send_after(self(), :tick_cleanup, @tick_cleanup_interval)

  defp clamp_position(position) do
    case position do
      n when n > @limit_y -> @limit_y
      n when n < 0 -> 0
      n -> n
    end
  end

  defp robot_move(state, speed) do
    robot = state.robot

    updated_robot =
      robot
      |> Map.put(:speed, speed)
      |> Map.put(:position_x, clamp_position(robot.position_x + speed.x))
      |> Map.put(:position_y, clamp_position(robot.position_y + speed.y))

    %{state | robot: updated_robot}
  end

  def robot_recalculate_speed(state) do
    speed =
      state.players
      |> Enum.reduce(%{x: 0, y: 0, total: 0}, fn player, acc ->
        case {player.position_x, player.position_y} do
          {x, y} when x > 230 and y < 210 and y > 80 ->
            %{x: acc.x + 1, y: acc.y, total: acc.total + 1}
          {x, y} when x < 50 and y < 210 and y > 80 ->
            %{x: acc.x - 1, y: acc.y, total: acc.total + 1}
          {x, y} when y < 50 and x < 210 and x > 90 ->
            %{x: acc.x, y: acc.y - 1, total: acc.total + 1}
          {x, y} when y > 230 and x < 210 and x > 90 ->
            %{x: acc.x, y: acc.y + 1, total: acc.total + 1}
          _ -> acc
        end
      end)

    case speed.total do
      0 -> %{x: 0, y: 0}
      _ -> %{x: speed.x/speed.total, y: speed.y/speed.total}
    end
  end

  def robot_check_collisions(state = %{robot: robot}, obstacles) do
    obstacles
    |> Enum.reduce(:none, fn obstacle, acc ->
      case acc do
        :none ->
          Demo.Robot.check_collision(robot, obstacle)
        _ -> acc
      end
    end)
    |> case do
      :none -> state
      :win ->
        robot_update_state(state, :won)
      _ ->
        # :death and others
        robot_update_state(state, :lost)
    end
  end

  def robot_update_state(state, robot_state_name) do
    robot =
      state.robot
      |> Map.put(:state, robot_state_name)

    %{state | robot: robot}
  end

  def robot_restart_if_needed(state = %{robot: robot}) do
    case robot.state do
      :lost ->
        state
        |> save_loss_info()
        |> robot_restart()
      :won ->
        state
        |> save_win_info()
        |> robot_restart()
      _ -> state
    end
  end

  def robot_restart(state) do
    %{state | robot: @robot_init}
  end

  def save_win_info(state) do
    game = state.game
    new_game = %{game | last_win: timestamp()}

    %{state | game: new_game}
  end

  def save_loss_info(state) do
    game = state.game
    new_game = %{game | last_loss: timestamp()}

    %{state | game: new_game}
  end

  defp timestamp() do
    Demo.Time.timestamp()
  end
end

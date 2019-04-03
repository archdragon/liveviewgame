
defmodule Demo.Store do
  use GenServer

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

  def handle_call({:get_all}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:register_player, player_data}, _from, state) do
    IO.puts("Registering player")
    IO.inspect(player_data)

    new_players = [player_data | state.players]

    new_state = %{state | players: new_players}

    {:reply, new_state, new_state}
  end

  def handle_cast({:move, user_id, x, y}, state) do
    x = x * 30
    y = y * 30

    new_players =
      state.players
      |> Enum.map(fn player ->
        case player.user_id == user_id do
          true ->
            %{player | position_x: player.position_x + x, position_y: player.position_y + y}
          false ->
            player
        end
      end)

    new_state = %{state | players: new_players}

    {:noreply, new_state}
  end

  # TODO: Cast will be enough
  def handle_call({:replace_last, search_term}, _from, state) do
    timestamp = System.system_time(:second)
    new_item = %{text: search_term, timestamp: timestamp}

    new_state =
      case state do
        [] -> [new_item]
        state -> List.replace_at(state, 0, new_item)
      end

    {:reply, :ok, new_state}
  end

  def init(_args) do
    {:ok, %{
      players: [],
      ship: %{
        position_x: 0, # from -100 to 100
        position_y: 0, # from -100 to 100
        speed: 0 # from -1 to 1
      }
    }}
  end
end

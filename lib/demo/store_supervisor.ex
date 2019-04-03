defmodule Demo.StoreSupervisor do
  alias Demo.Store
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Store, [[name: Store]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

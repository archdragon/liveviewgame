
defmodule Demo.Time do
  def timestamp() do
    System.system_time(:second)
  end
end

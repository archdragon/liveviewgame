
defmodule Demo.Time do
  def timestamp() do
    :os.system_time(:seconds)
  end
end

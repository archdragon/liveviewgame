defmodule Demo.ObstacleCourse do
  @obstacles [
    %{x: 0, y: 100, size_x: 200, size_y: 40, kind: :death},
    %{x: 250, y: 100, size_x: 50, size_y: 20, kind: :death}
  ]

  def obstacles() do
    @obstacles
  end
end

defmodule Demo.ObstacleCourse do
  @obstacles [
    %{x: -50, y: 100, size_x: 225, size_y: 40, kind: :death},
    %{x: 250, y: 50, size_x: 100, size_y: 100, kind: :death},
    %{x: 170, y: 200, size_x: 150, size_y: 150, kind: :death},
    %{x: 25, y: 250, size_x: 50, size_y: 50, kind: :win}
  ]

  def obstacles() do
    @obstacles
  end
end

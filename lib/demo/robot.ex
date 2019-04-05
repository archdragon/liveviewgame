defmodule Demo.Robot do
  # def collision_info(robot_x, robot_y, area_items) do
  #   {:death}
  #   {:exit}
  #   {:none}
  # end
  @robot_size 25

  def check_collision(robot, obstacle) do
    min_x = obstacle.x
    max_x = obstacle.x + obstacle.size_x
    min_y = obstacle.y
    max_y = obstacle.y + obstacle.size_y

    robot_x = robot.position_x + @robot_size / 2
    robot_y = robot.position_y + @robot_size / 2

    case {robot_x, robot_y} do
      {x, y} when x >= min_x and x <= max_x and y >= min_y and y <= max_y -> obstacle.kind
      _ -> :none
    end
  end
end

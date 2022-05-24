defmodule Machine do

  @moduledoc """
    ISTRUZIONI
    :forward
    :turn_left
    :turn_right
    :paint_red
    :paint_green
    :paint_blue
    :jump_f0
    :jump_f1
    :jump_f2
  """
  def evaluate(game_map, stars, spaceship, program, pc \\ %ProgramCounter{}) do
    instruction = Enum.at(program, pc.func) |> Enum.at(pc.addr)
    current_color = Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX)

    {new_game_map, new_stars, new_spaceship, new_pc} = case instruction do
      :forward -> spaceship_forward(game_map, stars, spaceship, pc)
      :turn_left -> spaceship_turn_left(game_map, stars, spaceship, pc)
      :turn_right -> spaceship_turn_right(game_map, stars, spaceship, pc)
      :paint_red -> paint(game_map, stars, spaceship, pc, :red)
      :paint_green -> paint(game_map, stars, spaceship, pc, :green)
      :paint_blue -> paint(game_map, stars, spaceship, pc, :blue)
      :jump_f0 -> jump(game_map, stars, spaceship, pc, 0)
      :jump_f1 -> jump(game_map, stars, spaceship, pc, 1)
      :jump_f2 -> jump(game_map, stars, spaceship, pc, 2)
      {:forward, ^current_color} -> spaceship_forward(game_map, stars, spaceship, pc)
      {:turn_left, ^current_color} -> spaceship_turn_left(game_map, stars, spaceship, pc)
      {:turn_right, ^current_color} -> spaceship_turn_right(game_map, stars, spaceship, pc)
      {:paint_red, ^current_color} -> paint(game_map, stars, spaceship, pc, :red)
      {:paint_green, ^current_color} -> paint(game_map, stars, spaceship, pc, :green)
      {:paint_blue, ^current_color} -> paint(game_map, stars, spaceship, pc, :blue)
      {:jump_f0, ^current_color} -> jump(game_map, stars, spaceship, pc, 0)
      {:jump_f1, ^current_color} -> jump(game_map, stars, spaceship, pc, 1)
      {:jump_f2, ^current_color} -> jump(game_map, stars, spaceship, pc, 2)
      _ ->  {game_map, stars, spaceship, pc}
    end

    incr_pc = %{pc | addr: new_pc.addr + 1}
    check_game_status(new_game_map, new_stars, new_spaceship, program, incr_pc)
  end

  def check_game_status(game_map, stars, spaceship, program, pc) do
    cond do
      length(stars) == 0 ->
          {:win, program}
      Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX) == nil ->
          {:lose, program}
      Enum.at(program, pc.func) |> length <= pc.addr ->
          {:lose, program}
      true ->
          evaluate(game_map, stars, spaceship, program, pc)
    end
  end

  def spaceship_forward(game_map, stars, spaceship, pc) do
    new_spaceship = case spaceship.direction do
      :up -> %{spaceship | posY: spaceship.posY + 1}
      :down -> %{spaceship | posY: spaceship.posY - 1}
      :right -> %{spaceship | posX: spaceship.posX + 1}
      :left -> %{spaceship | posX: spaceship.posX - 1}
    end
    new_stars = Enum.filter(stars, fn {y, x} -> not(x == new_spaceship.posX and y == new_spaceship.posY) end)
    {game_map, new_stars, new_spaceship, pc}
  end

  def spaceship_turn_left(game_map, stars, spaceship, pc) do
    case spaceship.direction do
      :up -> {game_map, stars, %{spaceship | direction: :left}, pc}
      :left -> {game_map, stars, %{spaceship | direction: :down}, pc}
      :down -> {game_map, stars, %{spaceship | direction: :right}, pc}
      :right -> {game_map, stars, %{spaceship | direction: :up}, pc}
    end
  end

  def spaceship_turn_right(game_map, stars, spaceship, pc) do
    case spaceship.direction do
      :up -> {game_map, stars, %{spaceship | direction: :right}, pc}
      :right -> {game_map, stars, %{spaceship | direction: :down}, pc}
      :down -> {game_map, stars, %{spaceship | direction: :left}, pc}
      :left -> {game_map, stars, %{spaceship | direction: :up}, pc}
    end
  end

  def paint(game_map, stars, spaceship, pc, color) do
    new_row = Enum.at(game_map, spaceship.posY) |> List.replace_at(spaceship.posX, color)
    new_game_map = List.replace_at(game_map, spaceship.posY, new_row)
    {new_game_map, stars, spaceship, pc}
  end

  def jump(game_map, stars, spaceship, _, func) do
    {game_map, stars, spaceship, %ProgramCounter{func: func, addr: -1}}
  end


end

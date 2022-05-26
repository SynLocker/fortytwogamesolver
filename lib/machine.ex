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
    pid = self()
    spawn_link(fn -> :timer.sleep(3000); send(pid, {:die}) end)

    do_evaluate(game_map, stars, spaceship, program, pc)
  end

  def do_evaluate(game_map, stars, spaceship, program, pc) do
    instruction = Enum.at(program, pc.func) |> Enum.at(pc.addr)
    current_color = Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX)

    {new_game_map, new_stars, new_spaceship, new_pc} = case instruction do
      {:forward, :grey} -> spaceship_forward(game_map, stars, spaceship, pc)
      {:turn_left, :grey} -> spaceship_turn_left(game_map, stars, spaceship, pc)
      {:turn_right, :grey} -> spaceship_turn_right(game_map, stars, spaceship, pc)
      {:paint_red, :grey} -> paint(game_map, stars, spaceship, pc, :red)
      {:paint_green, :grey} -> paint(game_map, stars, spaceship, pc, :green)
      {:paint_blue, :grey} -> paint(game_map, stars, spaceship, pc, :blue)
      {:jump_f0, :grey} -> jump(game_map, stars, spaceship, pc, 0)
      {:jump_f1, :grey} -> jump(game_map, stars, spaceship, pc, 1)
      {:jump_f2, :grey} -> jump(game_map, stars, spaceship, pc, 2)
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

    incr_pc = %{new_pc | addr: new_pc.addr + 1}
    check_game_status(new_game_map, new_stars, new_spaceship, program, incr_pc)
  end

  def check_game_status(game_map, stars, spaceship, program, pc) do
    receive do
      {:die} ->
        send(Process.whereis(:main_sup), {:loop, program})
        exit(:normal)
    after
       0 -> :ok
    end

    cond do
      length(stars) == 0 ->
          send(Process.whereis(:main_sup), {:win, program})
      Enum.at(game_map, spaceship.posY) == nil ->
          send(Process.whereis(:main_sup), {:lose, program})
      Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX) == nil ->
          send(Process.whereis(:main_sup), {:lose, program})
      Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX) == :grey ->
          send(Process.whereis(:main_sup), {:lose, program})
      Enum.at(program, pc.func) |> length <= pc.addr ->
          send(Process.whereis(:main_sup), {:lose, program})
      true ->
        do_evaluate(game_map, stars, spaceship, program, pc)
    end
  end

  def spaceship_forward(game_map, stars, spaceship, pc) do
    new_spaceship = case spaceship.direction do
      :up -> %{spaceship | posY: spaceship.posY + 1}
      :down -> %{spaceship | posY: spaceship.posY - 1}
      :right -> %{spaceship | posX: spaceship.posX + 1}
      :left -> %{spaceship | posX: spaceship.posX - 1}
    end
    new_stars = Enum.filter(stars, fn {x, y} -> not(x == new_spaceship.posX and y == new_spaceship.posY) end)
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
#Machine.evaluate(Main.game_map, Main.stars, Main.spaceship, [program|])
#program = [[{:jump_f0, :grey}]|[]]

defmodule Machine do

  @available_time 3000
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
    {:ok, obs_pid} = Task.start(__MODULE__, :observer, [self()])
    do_evaluate(game_map, stars, spaceship, program, pc, obs_pid)
  end

  def do_evaluate(game_map, stars, spaceship, program, pc, obs_pid) do
    instruction = Enum.at(program, pc.func) |> Enum.at(pc.addr)
    current_color = Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX)

    {new_game_map, new_stars, new_spaceship, new_pc} = case instruction do
      {:forward, color} when color in [:grey, current_color] -> spaceship_forward(game_map, stars, spaceship, pc)
      {:turn_left, color} when color in [:grey, current_color] -> spaceship_turn_left(game_map, stars, spaceship, pc)
      {:turn_right, color} when color in [:grey, current_color] -> spaceship_turn_right(game_map, stars, spaceship, pc)
      {:paint_red, color} when color in [:grey, current_color] -> paint(game_map, stars, spaceship, pc, :red)
      {:paint_green, color} when color in [:grey, current_color] -> paint(game_map, stars, spaceship, pc, :green)
      {:paint_blue, color} when color in [:grey, current_color] -> paint(game_map, stars, spaceship, pc, :blue)
      {:jump_f0, color} when color in [:grey, current_color] -> jump(game_map, stars, spaceship, pc, 0)
      {:jump_f1, color} when color in [:grey, current_color] -> jump(game_map, stars, spaceship, pc, 1)
      {:jump_f2, color} when color in [:grey, current_color] -> jump(game_map, stars, spaceship, pc, 2)
      _ ->  {game_map, stars, spaceship, pc}
    end

    incr_pc = %{new_pc | addr: new_pc.addr + 1}
    check_game_status(new_game_map, new_stars, new_spaceship, program, incr_pc, obs_pid)
  end

  def check_game_status(game_map, stars, spaceship, program, pc, obs_pid) do
    receive do
      {:die} ->
        {:lose}
    after
       0 ->
        cond do
          length(stars) == 0 ->
            send(obs_pid, {:die})
            {:win, program}
          Enum.at(game_map, spaceship.posY) == nil ->
            send(obs_pid, {:die})
            {:lose}
          Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX) == nil ->
            send(obs_pid, {:die})
            {:lose}
          Enum.at(game_map, spaceship.posY) |> Enum.at(spaceship.posX) == :grey ->
            send(obs_pid, {:die})
            {:lose}
          Enum.at(program, pc.func) |> length <= pc.addr ->
            send(obs_pid, {:die})
            {:lose}
          true ->
            do_evaluate(game_map, stars, spaceship, program, pc, obs_pid)
        end
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

  def observer(pid) do
    receive do
      {:die} ->
        exit(:normal)
      after
        @available_time ->
          send(pid, {:die})
    end

  end
end
#Machine.evaluate(Main.game_map, Main.stars, Main.spaceship, [program|])
#program = [[{:jump_f0, :grey}]|[]]

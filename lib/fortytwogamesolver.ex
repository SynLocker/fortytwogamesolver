defmodule Fortytwogamesolver do
  @moduledoc """
  Documentation for `Fortytwogamesolver`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Fortytwogamesolver.hello()
      :world

  """
  def main(_) do
    game_map = [[:blue, :red, :red],
                [:red, :red, :red],
                [:blue, :red, :red]] |> Enum.reverse
    stars = [{2,0}]
    spaceship = %Spaceship{posX: 2, posY: 2, direction: :left}
    program = [[{:forward, :grey}, {:turn_left, :blue}, {:jump_f0, :grey}]]
    IO.inspect(Machine.evaluate(game_map, stars, spaceship, program))
  end



  def find_solution(game_map, cmds, _func_sizes, stars, spaceship) do
    colors = [:red, :blue, :green, :grey]
    color_perm = Combinatorial.perm_rep(colors, 3)
    cmds_perm = Combinatorial.perm_rep(cmds, 3)
    for f <- cmds_perm, c <- color_perm do
      IO.inspect(Enum.zip(f,c))
      case Machine.evaluate(game_map, stars, spaceship, [Enum.zip(f,c)]) do
        {:win, p} -> IO.inspect(p)
        _ -> :ok
      end
    end
    :ok
  end

end

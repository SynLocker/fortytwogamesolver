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
    game_map = [[:red, :red, :red], [:red, :red, :red], [:red, :red, :red]]
    stars = [{2,0}]
    spaceship = %Spaceship{posX: 2, posY: 2, direction: :left}
    program = [[:forward, :forward]]
    IO.puts(Machine.evaluate(game_map, stars, spaceship, program))
  end
end

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
    stars = [{0,2}]
    spaceship = %Spaceship{posX: 2, posY: 2, direction: :left}
    program = [[:forward, :forward]]
    IO.inspect(Machine.evaluate(game_map, stars, spaceship, program))
  end
end

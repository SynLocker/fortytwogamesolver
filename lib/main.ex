defmodule Main do


  def game_map, do: [[:blue, :red, :red],
                    [:red, :red, :red],
                    [:blue, :red, :red]] |> Enum.reverse

  def stars, do: [{2,0}]
  def spaceship, do: %Spaceship{posX: 2, posY: 2, direction: :left}
  def cmds, do: [:forward, :turn_left, :jump_f0]
  def fun_len, do: [3]

  def main() do
    find_solution(game_map, cmds, fun_len, stars, spaceship)
  end



  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 1 do
    {:ok, file} = File.open "data.log", [:append, {:delayed_write, 100, 20}]

    seed = gen_seed(cmds, fun_len)
    {colors, instr} = Enum.at(seed, 0)

    for i <- instr, c <- colors do
      gen_machines(game_map, stars, spaceship, [Enum.zip(i,c)], file)
    end
    :ok
  end

  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 2 do
    {:ok, file} = File.open "data.log", [:append, {:delayed_write, 100, 20}]

    seed = gen_seed(cmds, fun_len)
    {colors_0, instr_0} = Enum.at(seed, 0)
    {colors_1, instr_1} = Enum.at(seed, 1)

    for i_0 <- instr_0, c_0 <- colors_0, i_1 <- instr_1, c_1 <- colors_1 do
      gen_machines(game_map, stars, spaceship, [Enum.zip(i_0,c_0), Enum.zip(i_1,c_1)], file)
    end
    :ok
  end

  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 3 do
    {:ok, file} = File.open "data.log", [:append, {:delayed_write, 100, 20}]

    seed = gen_seed(cmds, fun_len)
    {colors_0, instr_0} = Enum.at(seed, 0)
    {colors_1, instr_1} = Enum.at(seed, 1)
    {colors_2, instr_2} = Enum.at(seed, 2)

    for i_0 <- instr_0, c_0 <- colors_0, i_1 <- instr_1, c_1 <- colors_1,  i_2 <- instr_2, c_2 <- colors_2 do
      gen_machines(game_map, stars, spaceship, [Enum.zip(i_0,c_0), Enum.zip(i_1,c_1), Enum.zip(i_2,c_2)], file)
    end
    :ok
  end

  def gen_seed(cmds, fun_len) do
    colors = [:red, :blue, :green, :grey]
    (for fs <- fun_len , do: Combinatorial.perm_rep(colors, fs))
      |> Enum.zip(for fs <- fun_len , do: Combinatorial.perm_rep(cmds, fs))
  end

  def gen_machines(game_map, stars, spaceship, program, file) do
    spawn(fn ->
            case Machine.evaluate(game_map, stars, spaceship, program) do
              {:win, p} -> IO.binwrite(file, Kernel.inspect(p) <> "\n")
              _ -> :ok
            end
          end
        )
  end

end

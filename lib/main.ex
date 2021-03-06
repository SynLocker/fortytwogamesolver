defmodule Main do

  def max_process, do: 200000

  def game_map, do: [
    [:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:blue,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:grey,:red,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:grey,:grey,:red,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey],
    [:grey,:grey,:grey,:grey,:grey,:red,:red,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey,:grey]
  ] |> Enum.reverse

  def stars, do: [{6,0}]
  def spaceship, do: %Spaceship{posX: 2, posY: 7, direction: :down}
  def cmds, do: [:turn_right, :turn_left, :forward, :jump_f0]
  def fun_len, do: [6]

  def n_programs do
    for l <- fun_len do (length(cmds) |> :math.pow(l)) * :math.pow(4, l) end
    |> List.foldl(1, fn el, acc -> el*acc end)
    |> trunc
  end

  def start() do
    Scheduler.start
    spawn(fn -> supervisor end)
  end

  def status do
    send(Process.whereis(:main_sup), {:status})
  end

  def status_loop do
    :timer.sleep(5000)
    status()
    status_loop()
  end
  def supervisor(active_processes \\ 0, solution_checked \\ 0, spawn \\ :true)

  def supervisor(active_processes, solution_checked, :true) do
    Process.register(self(), :main_sup)
    spawn_link(fn -> find_solution(game_map, cmds, fun_len, stars, spaceship) end)
    supervisor(active_processes, solution_checked, :false)
  end

  def supervisor(active_processes, solution_checked, :false) do
    receive do
      {:win, program} ->
        IO.inspect(program)
        supervisor(active_processes - 1, solution_checked + 1, :false)
      {:lose} ->
        supervisor(active_processes - 1, solution_checked + 1, :false)
      {:new} ->
        supervisor(active_processes + 1, solution_checked, :false)
      {:status} ->
        IO.puts("Active processes: #{active_processes} Solutions checked: #{solution_checked}/#{n_programs()}")
        supervisor(active_processes, solution_checked, :false)
    end

  end

  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 1 do
    seed = gen_seed(cmds, fun_len)
    {colors, instr} = Enum.at(seed, 0)

    for i <- instr, c <- colors do
        Scheduler.execute_program({game_map, stars, spaceship, [Enum.zip(i,c)]})
    end
    :ok
  end

  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 2 do
    seed = gen_seed(cmds, fun_len)
    {colors_0, instr_0} = Enum.at(seed, 0)
    {colors_1, instr_1} = Enum.at(seed, 1)

    for i_0 <- instr_0, c_0 <- colors_0, i_1 <- instr_1, c_1 <- colors_1 do
      Scheduler.execute_program({game_map, stars, spaceship, [Enum.zip(i_0,c_0), Enum.zip(i_1,c_1)]})
    end
    :ok
  end

  def find_solution(game_map, cmds, fun_len, stars, spaceship) when length(fun_len) == 3 do
    seed = gen_seed(cmds, fun_len)
    {colors_0, instr_0} = Enum.at(seed, 0)
    {colors_1, instr_1} = Enum.at(seed, 1)
    {colors_2, instr_2} = Enum.at(seed, 2)

    for i_0 <- instr_0, c_0 <- colors_0, i_1 <- instr_1, c_1 <- colors_1,  i_2 <- instr_2, c_2 <- colors_2 do
      Scheduler.execute_program({game_map, stars, spaceship, [Enum.zip(i_0,c_0), Enum.zip(i_1,c_1), Enum.zip(i_2,c_2)]})
    end
    :ok
  end

  def gen_seed(cmds, fun_len) do
    colors = [:red, :blue, :green, :grey]
    (for fs <- fun_len , do: Combinatorial.perm_rep(colors, fs))
      |> Enum.zip(for fs <- fun_len , do: Combinatorial.perm_rep(cmds, fs))
  end
end

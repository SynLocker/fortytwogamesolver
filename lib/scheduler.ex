defmodule Scheduler do

  @max_process 50

  def start do
    Task.start_link(fn -> init() end)
  end

  defp init do
    Process.register(self(), :scheduler)
    max_process = @max_process
    (for _i <- 1..max_process, do: Task.start(Thread, :loop, []))
      |> Enum.map(&(elem(&1, 1)))
      |> loop()
    :ok
  end

  defp loop(pids, queue \\ []) do
    receive do
      {:run_program, game, sender} when pids == [] ->
        loop(pids, [{game, sender} | queue])

      {:run_program, game, sender} when queue != [] ->
        loop(pids, [{game, sender} | queue])

      {:run_program, game, sender} ->
        [pid | new_pids] = pids
        send(pid, {:run, game})
        send(sender, {:runned})
        loop(new_pids, queue)

      {:process_available, pid} when queue == [] ->
        loop([pid | pids], queue)

      {:process_available, pid} ->
        [{game, sender} | new_queue] = queue
        send(pid, {:run, game})
        send(sender, {:runned})
        loop(pids, new_queue)
    end
  end

  def execute_program(game) do
    send(Process.whereis(:scheduler), {:run_program, game, self()})
    receive do
      {:runned} ->
        :ok
    end
  end
end

defmodule Thread do
  def loop do
    receive do
      {:run, game} ->
        send(Process.whereis(:main_sup), {:new})
        {game_map, stars, spaceship, program} = game
        result = Machine.evaluate(game_map, stars, spaceship, program)
        send(Process.whereis(:main_sup), result)
        send(Process.whereis(:scheduler), {:process_available, self()})
        loop()
    end
  end
end

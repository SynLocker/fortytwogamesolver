defmodule CombinatorialUtility do
  def perm_rep(list), do: perm_rep(list, length(list))

  def perm_rep([], _), do: [[]]
  def perm_rep(_,  0), do: [[]]
  def perm_rep(list, i) do
    for x <- list, y <- perm_rep(list, i-1), do: [x|y]
  end
end

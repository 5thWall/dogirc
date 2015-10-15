defmodule Dogirc.UtilTest do
  use ExUnit.Case

  import Dogirc.Util

  test "find_and_replace replaces items" do
    result =
      [1, 2, 3, 4]
      |> find_and_replace(&(rem(&1, 2) == 0), &(&1 + 1))

    assert result == [1, 3, 3, 5]
  end

  test "map_if returns mapped values if predicate is true" do
    assert map_if(10, &(rem(&1, 2) == 0), &(&1 + 1)) == 11
  end

  test "map_if returns original value if predicate is false" do
    assert map_if(11, &(rem(&1, 2) == 0), &(&1 + 1)) == 11
  end
end

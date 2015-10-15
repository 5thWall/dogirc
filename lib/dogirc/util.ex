defmodule Dogirc.Util do
  @moduledoc """
  Utilities that don't specifically belong in the module where they're used.
  """

  @doc """
  Replaces the first match of a function with the value run through the
  transformation function.
  """
  def find_and_replace(list, filter, mapper) do
    Enum.map(list, &map_if(&1, filter, mapper))
  end

  def map_if(item, filter, mapper) do
    if filter.(item) do
      mapper.(item)
    else
      item
    end
  end
end

defmodule Dogirc.Plugin.UserList.NameSupervisor do
  @moduledoc """
  Module for supervising NameBuckets
  """

  @module __MODULE__

  use Supervisor

  alias Dogirc.Plugin.UserList.NameBucket

  def start_link(opts \\ []) do
    Supervisor.start_link(@module, :ok, opts)
  end

  def start_bucket(supervisor, users) do
    Supervisor.start_child(supervisor, [users])
  end

  def init(:ok) do
    children = [
      worker(NameBucket, [], type: :temporary)
    ]
    supervise children, strategy: :simple_one_for_one
  end
end

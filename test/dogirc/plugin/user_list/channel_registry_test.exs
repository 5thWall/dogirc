defmodule Dogirc.Plugin.UserList.ChannelRegistryTest do
  use ExUnit.Case

  alias Dogirc.Plugin.UserList.ChannelRegistry
  alias Dogirc.Plugin.UserList.NameBucket
  alias Dogirc.Plugin.UserList.NameSupervisor
  alias Dogirc.User

  @users [
    %User{
      nick: "neo",
      username: "theone",
      host: "matrix"
    },
    %User{
      nick: "FifthWall",
      username: "andy",
      host: "localhost"
    }
  ]

  setup do
    {:ok, sup} = NameSupervisor.start_link
    {:ok, reg} = ChannelRegistry.start_link(sup)
    {:ok, registry: reg}
  end

  test "spawns buckets", %{registry: reg} do
    assert ChannelRegistry.lookup(reg, "#dogirc") == :error

    ChannelRegistry.create(reg, "#dogirc", @users)
    assert {:ok, bucket} = ChannelRegistry.lookup(reg, "#dogirc")

    assert NameBucket.list_users(bucket) == @users
  end

  test "removes buckets", %{registry: reg} do
    ChannelRegistry.create(reg, "#dogirc", @users)
    {:ok, bucket} = ChannelRegistry.lookup(reg, "#dogirc")
    ChannelRegistry.remove(reg, "#dogirc")

    assert ChannelRegistry.lookup(reg, "#dogirc") == :error

    refute Process.alive?(bucket)
  end
end

defmodule Dogirc.Plugin.UserList.NameBucketTest do
  use ExUnit.Case

  alias Dogirc.Plugin.UserList.NameBucket, as: NB
  alias Dogirc.User

  @neo %User{
    nick: "neo",
    username: "theone",
    host: "matrix"
  }

  @fifthwall %User{
    nick: "FifthWall",
    username: "5thWall",
    host: "localhost"
  }

  @notneo %User{
    nick: "NotNeo",
    username: "5thWall",
    host: "localhost"
  }

  @bob %User{
    nick: "Bob",
    username: "Robbert",
    host: "example.com"
  }

  @users [@neo, @fifthwall]

  setup do
    {:ok, bucket} = NB.start_link(@users)
    {:ok, bucket: bucket}
  end

  test "lists inital users", %{bucket: bucket} do
    assert NB.list_users(bucket) == @users
  end

  test "Adds users", %{bucket: bucket} do
    NB.add_user(bucket, @bob)
    assert NB.list_users(bucket) == [@bob | @users]
  end

  test "removes users", %{bucket: bucket} do
    NB.remove_user(bucket, @fifthwall)
    assert NB.list_users(bucket) == [@neo]
  end

  test "changes nicknames", %{bucket: bucket} do
    NB.update_nick(bucket, "FifthWall", "NotNeo")
    assert NB.list_users(bucket) == [@neo, @notneo]
  end
end

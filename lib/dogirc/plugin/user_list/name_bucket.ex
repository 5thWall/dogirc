defmodule Dogirc.Plugin.UserList.NameBucket do
  @moduledoc """
  Bucket that contains a list of users
  """

  import Dogirc.Util, only: [find_and_replace: 3]

  def start_link(users) do
    Agent.start_link(fn -> users end)
  end

  def add_user(bucket, user) do
    Agent.update(bucket, fn users -> [user | users] end)
  end

  def remove_user(bucket, user) do
    Agent.update(bucket, &List.delete(&1, user))
  end

  def list_users(bucket) do
    Agent.get(bucket, &(&1))
  end

  def update_nick(bucket, old_nick, new_nick) do
    Agent.update(bucket, &do_update_user(&1, old_nick, new_nick))
  end

  defp do_update_user(users, old, new) do
    find_and_replace(users,
                     fn %{nick: nick} -> nick == old end,
                     fn user -> %{user | nick: new} end)
  end
end

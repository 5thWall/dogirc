defmodule DogIRC.Commands do
  @moduledoc """
  Generates properly formatted IRC commands.
  """

  @doc "Command to change IRC nickname"
  def nick(nick),
  do: "NICK #{nick}\r\n"

  @doc """
  Command to set user information. Hostname and servername are usually
  ignored by servers, but they can still be specified.
  """
  def user(username, realname, hostname \\ "foo", servername \\ "bar"),
  do: "USER #{username} #{hostname} #{servername} #{realname}\r\n"

  @doc "Command to join a channel"
  def join(channel),
  do: "JOIN #{channel}\r\n"

  @doc "Command to send a message to a channel or user"
  def privmsg(target, message),
  do: "PRIVMSG #{target} :#{message}\r\n"

  @doc "Command to sand an action to a channel"
  def action(target, action),
  do: privmsg(target, "\x01ACTION #{action}\x01")

  @doc "Command to send a notice to a channel or server"
  def notice(target, message),
  do: "NOTICE #{target} :#{message}\r\n"

  @doc "Command to quit IRC"
  def quit,
  do: "QUIT\r\n"

  @doc "Command to quit IRC with a part message"
  def quit(reason),
  do: "QUIT :#{reason}\r\n"
end

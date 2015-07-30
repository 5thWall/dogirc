defmodule DogIRC.CommandTest do
  @user %User{nick: "neo"}

  use ExUnit.Case, async: true
  alias DogIRC.Command

  test "private message to a channel" do
    assert Command.to_command(%{command: 'PRIVMSG', prefix: 'neo', params: ['#matrix', "I am the one"]}) == %Command{from: @user, type: :privmsg, target: '#matrix', message: "I am the one"}
  end

  test "action message to a channel" do
    assert Command.to_command(%{command: 'PRIVMSG', prefix: 'neo', params: ['#matrix', "\x01ACTION flies away\x01"]}) == %Command{from: @user, type: :action, target: '#matrix', message: "flies away"}
  end

  test "notice message to a channel" do
    assert Command.to_command(%{command: 'NOTICE', prefix: 'neo', params: ['#matrix', "bots should not reply"]}) == %Command{from: @user, type: :notice, target: '#matrix', message: "bots should not reply"}
  end
end

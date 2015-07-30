defmodule DogIRC.ParserTest do
  @user %User{nick: "neo"}

  use ExUnit.Case, async: true
  alias DogIRC.Parser

  test "converts to internal representation" do
    assert Parser.parse(":neo PRIVMSG #matrix :I am the one") == %{prefix: 'neo', command: 'PRIVMSG', params: ['#matrix', "I am the one"]}

    assert Parser.parse(":neo PRIVMSG #matrix,#test :I am the one") == %{prefix: 'neo', command: 'PRIVMSG', params: ['#matrix,#test', "I am the one"]}
  end
end


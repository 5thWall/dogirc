defmodule DogIRC.ParserTest do
  use ExUnit.Case, async: true
  alias DogIRC.Parser

  test "private message to a channel" do
    assert Parser.parse(":neo PRIVMSG #matrix :I am the one") == %Command{from: %User{nick: "neo"}, type: :privmsg, target: '#matrix', message: "I am the one"}
  end
end


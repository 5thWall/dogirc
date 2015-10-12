defmodule Dogirc.ParserTest do
  use ExUnit.Case, async: true
  alias Dogirc.Parser

  test "converts to internal representation" do
    assert Parser.parse(":neo PRIVMSG #matrix :I am the one")
           ==
           %{prefix: 'neo', command: 'PRIVMSG', params: ['#matrix', "I am the one"]}

    assert Parser.parse(":neo PRIVMSG #matrix,#test :I am the one")
           ==
           %{prefix: 'neo', command: 'PRIVMSG', params: ['#matrix,#test', "I am the one"]}
  end
end


defmodule UserTest do
  use ExUnit.Case, async: true

  test 'Parses user names in charlist format' do
    assert User.parse('FifthWall!textual@localhost') == %User{nick: "FifthWall", username: "textual", host: "localhost"}
  end

  test 'Parses usernames that are just nicks' do
    assert User.parse("FifthWall") == %User{nick: "FifthWall"}
  end

  test 'Parses usernames that have usernames' do
    assert User.parse("FifthWall!textual") == %User{nick: "FifthWall", username: "textual"}
  end

  test 'Parses usernames that have just hosts' do
    assert User.parse("FifthWall@localhost") == %User{nick: "FifthWall", host: "localhost"}
  end

  test 'Parses full usernames' do
    assert User.parse("FifthWall!textual@localhost") == %User{nick: "FifthWall", host: "localhost", username: "textual"}
  end
end



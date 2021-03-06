defmodule Dogirc.Command do
  @module __MODULE__

  defstruct from: "",
            type: :noop,
            target: "",
            message: ""

  alias Dogirc.User

  def to_command(%{command: 'PRIVMSG', params: [target, "\x01ACTION " <> message], prefix: user}) do
    %@module{
      type: :action,
      target: target,
      message: String.rstrip(message, 1),
      from: User.parse(user)
    }
  end

  def to_command(%{command: 'PRIVMSG', params: [target, message], prefix: user}) do
    %@module{
      type: :privmsg,
      target: target,
      message: message,
      from: User.parse(user)
    }
  end

  def to_command(%{command: 'NOTICE', params: [target, message], prefix: user}) do
    %@module{
      type: :notice,
      target: target,
      message: message,
      from: User.parse(user)
    }
  end

  def to_command(%{command: 'JOIN', params: [target], prefix: user}) do
    %@module{
      type: :join,
      target: target,
      from: User.parse(user)
    }
  end

  def to_command(%{command: 'PART', params: [target, message], prefix: user}) do
    %@module{
      type: :part,
      target: target,
      message: message,
      from: User.parse(user)
    }
  end

  def to_command(data), do: data
end

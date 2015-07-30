defmodule DogIRC.Parser do
  @module __MODULE__

  def parse(command) when is_binary(command) do
    command
    |> String.rstrip
    |> String.to_char_list
    |> :string.tokens(' ')
    |> parse
  end

  def parse([[?: | prefix] | message]) do
    Map.put(parse(message), :prefix, prefix)
    |> parse
  end

  def parse([command | params]) do
    %{ command: command, params: parse_params(params) }
    |> parse
  end

  def parse(%{command: 'PRIVMSG', params: [target, message], prefix: user}) do
    %Command{type: :privmsg, target: target, message: message, from: User.parse(user)}
  end

  def parse(data),
  do: data

  defp parse_params(params),
  do: parse_params(params, [])

  defp parse_params([], params),
  do: Enum.reverse params

  # If the parameters starts with a ':' then just return the end of the string
  defp parse_params([[?: | first] | rest], params) do
    [Enum.join([first | rest], " ") | params]
    |> Enum.reverse
  end

  defp parse_params([param | rest], params),
  do: parse_params(rest, [param | params])
end

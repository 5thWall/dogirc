defmodule DogIRC.Parser do
  defstruct prefix: "",
            command: "",
            params: []

  @name __MODULE__

  def parse(command) when is_binary(command) do
    command
    |> String.rstrip
    |> String.to_char_list
    |> :string.tokens(' ')
    |> parse
  end

  def parse([[?: | prefix] | message]) do
    %{ parse(message) | prefix: prefix }
    |> parse
  end

  def parse([command | params]) do
    %@name{ command: command, params: parse_params(params) }
    |> parse
  end

  def parse(data),
  do: data

  defp parse_params(params),
  do: parse_params(params, [])

  defp parse_params([], params),
  do: Enum.reverse params

  defp parse_params([[?: | first] | rest], params) do
    [Enum.join([first | rest], " ") | params]
    |> Enum.reverse
  end

  defp parse_params([param | rest], params),
  do: parse_params(rest, [param | params])
end

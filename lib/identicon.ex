defmodule Identicon do
  @moduledoc """
    Author: Rusiru Fernando
    This project will generate Identicons based on the username provided
  """

  @doc """
    This method will be the main method that is to be run

  ## Example

      iex> Identicon.main("Test")

  """
  def main(username) do
    username
    |> hash_username
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(username)
  end

  @doc """
    This method will hash the provided string username
    using the MD5 hashing algorithm.
  """
  def hash_username(username) when is_binary(username) do
    hex = :crypto.hash(:md5, username)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    This method will get the first 3 elements from the
    hex list to decide on the color for the identicon.
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # TODO: method 01
    # %Identicon.Image{hex: hex_list} = image
    # [r, g, b | _tail] = hex_list

    # TODO: method 02
#    %Identicon.Image{hex: [r, g, b | _tail]} = image # we only need the first 3 out of 16

    %Identicon.Image{image | color: {r, g, b}}  # appending the existing struct
  end

  @doc """
    This method is used to construct the 5x5 grid using the hex values.
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(fn(row) -> mirror_row(row) end)
      |> List.flatten       # used to make one single list by combining the nested lists
      |> Enum.with_index    # add indexes to the list -> [{value, index},..]

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    This method will mirror each row of the grid.
    `[145, 46, 200]` will output `[145, 46, 200, 46, 145]`
  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
    This method will filter out grid elements (squares) which have odd number of value.
    Identicons only color the even number squares.
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    This method will map the coordinates for the squares based on the grid.
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    This method will draw the image based on the pixel map and the color
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    This method will save the image to our hard disk
  """
  def save_image(image, username) do
    File.write("#{username}.png", image)
  end
end

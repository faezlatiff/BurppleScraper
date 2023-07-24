defmodule AtlasTest do
  use ExUnit.Case
  doctest Atlas

  test "greets the world" do
    assert Atlas.hello() == :world
  end
end

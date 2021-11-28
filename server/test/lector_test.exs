defmodule LectorTest do
  use ExUnit.Case
  doctest Lector

  test "greets the world" do
    assert Lector.hello() == :world
  end
end

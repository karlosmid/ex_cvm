defmodule ExCvmTest do
  use ExUnit.Case
  doctest ExCvm

  test "empty stream" do
    assert ExCvm.estimate([], 0) == Decimal.new("0")
  end

  test "stream with three uniqe elements and buffer size 3" do
    assert ExCvm.estimate([:a, :b, :c], 3) == Decimal.new("3")
  end

  test "stream with three uniqe elements and buffer size 1" do
    assert ExCvm.estimate([:a, :b, :c], 1) != Decimal.new("0")
  end
end

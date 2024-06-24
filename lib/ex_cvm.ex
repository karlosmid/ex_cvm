defmodule ExCvm do
  @moduledoc """
  Documentation for `ExCvm`.
  The CVM Algorithm for Estimating Distinct Elements in Streams.
  https://cs.stanford.edu/~knuth/papers/cvm-note.pdf
  """

  @spec __struct__() :: %ExCvm{buffer: [], p: float(), t: 0}

  # Step D1: Initialize t = 0, p = 1, B = []
  defstruct t: 0, p: Decimal.new(1), buffer: []

  def new() do
    %ExCvm{}
  end

  @doc """
  Estimates the number of distinct elements in a stream.

  ## Examples

      iex> ExCvm.estimate([:a, :b, :c], 3)
      Decimal.new("3")

  """
  @spec estimate(list(), integer()) :: Decimal.t()
  def estimate(stream, s) do
    estimator = new()
    process_stream(estimator, stream, s)
  end

  # Step D2: Done, return |B|/p
  defp process_stream(estimator, [], _s) do
    Decimal.div(length(estimator.buffer), estimator.p)
  end

  defp process_stream(
         %ExCvm{t: t, p: p, buffer: buffer},
         [a | rest],
         s
       ) do
    # Step D3: t = t + 1, a is the next element in the stream
    t = t + 1

    # Step D4: Remove a from B
    buffer = Enum.reject(buffer, fn {x, _u} -> x == a end)

    # Step D5: Maybe put a in B
    u = Decimal.from_float(:rand.uniform())

    if Decimal.compare(u, p) in [:gt, :eq] do
      process_stream(%ExCvm{t: t, buffer: buffer, p: p}, rest, s)
    else
      if length(buffer) < s do
        buffer = [{a, u} | buffer]
        process_stream(%ExCvm{t: t, buffer: buffer, p: p}, rest, s)
      else
        # Step D6: Maybe swap a into B
        {a_prime, u_prime} = Enum.max_by(buffer, fn {_x, u} -> u end)

        {p, buffer} =
          if Decimal.compare(u, u_prime) == :gt do
            {u, buffer}
          else
            {u_prime, List.keystore(buffer, a_prime, 0, {a, u})}
          end

        process_stream(%ExCvm{t: t, buffer: buffer, p: p}, rest, s)
      end
    end
  end
end

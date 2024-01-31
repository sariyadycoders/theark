defmodule TheArk.ResultsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Results` context.
  """

  @doc """
  Generate a result.
  """
  def result_fixture(attrs \\ %{}) do
    {:ok, result} =
      attrs
      |> Enum.into(%{
        name: "some name",
        obtained_marks: 42,
        total_marks: 42
      })
      |> TheArk.Results.create_result()

    result
  end
end

defmodule TheArk.TestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Tests` context.
  """

  @doc """
  Generate a test.
  """
  def test_fixture(attrs \\ %{}) do
    {:ok, test} =
      attrs
      |> Enum.into(%{
        subject: "some subject"
      })
      |> TheArk.Tests.create_test()

    test
  end
end
